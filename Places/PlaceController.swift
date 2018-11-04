//
//  PlaceController.swift
//  Places
//
//  Created by Алексей Воронов on 03/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    
    var place: Place
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(place: Place) {
        self.place = place
        title = place.name
        
        if place.locationActual != nil {
            coordinate = CLLocationCoordinate2D(latitude: place.locationActual!.lat, longitude: place.locationActual!.lon)
        } else {
            coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }
    
}

class PlaceController: UITableViewController {
    
    var place: Place?

    @IBOutlet var image: UIImageView!
    @IBOutlet var textName: UITextField!
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if place?.name != "" {
            navigationItem.title = place?.name
        } else {
            navigationItem.title = "New place".localize()
        }
        textName.text = place?.name
        image.image = place?.imageActual
        LocationManager.sharedInstance.requestAuthorization()
        mapView.delegate = self
        if place?.locationActual != nil {
            mapView.addAnnotation(PlaceAnnotation(place: place!))
            mapView.centerCoordinate = CLLocationCoordinate2D(latitude: place!.locationActual!.lat, longitude: place!.locationActual!.lon)
            mapView.showsUserLocation = false
        } else {
            mapView.showsUserLocation = true
            LocationManager.sharedInstance.getCurrentLocation { (location) in
                self.mapView.centerCoordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
            }
        }
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.gestureRecognizers = [lpgr]
    }
    
    @IBAction func doneButton(_ sender: Any) {
        savePlace()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareAction(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if place?.name != "" || place?.imageActual != nil || textName.text != "" || image.image != nil {
            alert.addAction(UIAlertAction(title: "Remove place".localize(), style: .destructive, handler: { (action) in
                CoreDataManager.sharedInstance.managedObjectContext.delete(self.place!)
                CoreDataManager.sharedInstance.saveContext()
                self.navigationController?.popViewController(animated: true)
            }))
        }
        alert.addAction(UIAlertAction(title: "Share".localize(), style: .default, handler: { (action) in
            var activities: [Any] = []
            if self.place?.imageActual != nil {
                activities.append(self.place?.imageActual as Any)
            }
            activities.append(self.place?.name ?? "")
            activities.append(self.place?.dateString as Any)
            let activityController = UIActivityViewController(activityItems: activities, applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localize(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func savePlace() {
        
        if textName.text == "" && image.image == nil {
            CoreDataManager.sharedInstance.managedObjectContext.delete(place!)
            CoreDataManager.sharedInstance.saveContext()
            return
        }
        
        if place?.name != textName.text || place?.imageActual != image.image {
            place?.date = NSDate()
        }
        
        place?.name = textName.text
        place?.imageActual = image.image
        place?.addCurrentLocation()
        
        CoreDataManager.sharedInstance.saveContext()
        
    }
    
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state != .began {
            return
        }
        let point = recognizer.location(in: mapView)
        let c = mapView.convert(point, toCoordinateFrom: mapView)
        place?.locationActual = LocationCoordinate(lat: c.latitude, lon: c.longitude)
        CoreDataManager.sharedInstance.saveContext()
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(PlaceAnnotation(place: place!))
    }
    
    let imagePicker: UIImagePickerController = UIImagePickerController()
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && indexPath.section == 0 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Take a photo".localize(), style: .default, handler: { (action) in
                self.imagePicker.sourceType = .camera
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "Choose from library".localize(), style: .default, handler: { (action) in
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }))
            if self.image.image != nil {
                alertController.addAction(UIAlertAction(title: "Remove image".localize(), style: .destructive, handler: { (action) in
                    self.image.image = nil
                }))
            }
            alertController.addAction(UIAlertAction(title: "Cancel".localize(), style: .cancel, handler: { (action) in
                
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }

}

extension PlaceController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension PlaceController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        pin.animatesDrop = true
        pin.isDraggable = true
        
        return pin
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        if newState == .ending {
            let newLocation = LocationCoordinate(lat: (view.annotation?.coordinate.latitude)!, lon: (view.annotation?.coordinate.longitude)!)
            place?.locationActual = newLocation
            CoreDataManager.sharedInstance.saveContext()
        }
    }
    
}
