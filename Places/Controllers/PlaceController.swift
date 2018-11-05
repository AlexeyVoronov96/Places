//
//  PlaceController.swift
//  Places
//
//  Created by Алексей Воронов on 03/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import MapKit

class PlaceController: UITableViewController {
    
    //MARK: - Properties
    var place: Place?
    let imagePicker: UIImagePickerController = UIImagePickerController()

    @IBOutlet var image: UIImageView!
    @IBOutlet var textName: UITextField!
    @IBOutlet var mapView: MKMapView!
    
    //MARK: - Loading view
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
        if place?.locationActual != nil {
            mapView.addAnnotation(PlaceAnnotation(place: place!))
            mapView.centerCoordinate = CLLocationCoordinate2D(latitude: place!.locationActual!.lat, longitude: place!.locationActual!.lon)
            mapView.showsUserLocation = false
        } else {
            LocationManager.sharedInstance.getCurrentLocation { (location) in
                self.mapView.centerCoordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
            }
            mapView.showsUserLocation = true
        }
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.gestureRecognizers = [lpgr]
        mapView.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    //MARK: - Navigation bar buttons
    @IBAction func doneButton(_ sender: Any) {
        savePlace()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareAction(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if place?.name != "" || place?.imageActual != nil || textName.text != "" || image.image != nil {
            alert.addAction(UIAlertAction(title: "Remove place".localize(), style: .destructive, handler: { (action) in
                self.deletePlace()
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
    
    //MARK: - Working with data
    func savePlace() {
        
        if textName.text == "" && image.image == nil {
            self.deletePlace()
            return
        }
        
        if place?.name != textName.text || place?.imageActual != image.image {
            place?.date = NSDate()
        }
        
        if place?.locationActual == nil {
            place?.addCurrentLocation()
        }
        
        place?.name = textName.text
        place?.imageActual = image.image
        
        CoreDataManager.sharedInstance.saveContext()
        
    }
    
    func deletePlace() {
        CoreDataManager.sharedInstance.managedObjectContext.delete(self.place!)
        CoreDataManager.sharedInstance.saveContext()
    }
    
    //MARK: - Changing location with long press
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
    
    //MARK: - Hiding keyboard
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Adding image
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

//MARK: - Working with image picker
extension PlaceController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Working with map annotation
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
