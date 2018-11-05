//
//  MapController.swift
//  Places
//
//  Created by Алексей Воронов on 03/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet var mapView: MKMapView!
    
    //MARK: - Loading view
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.gestureRecognizers = [lpgr]
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        mapView.removeAnnotations(mapView.annotations)
        for place in places {
            if place.locationActual != nil {
                mapView.addAnnotation(PlaceAnnotation(place: place))
            }
        }
    }
    
    //MARK: - Processing long press
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state != .began {
            return
        }
        let point = recognizer.location(in: mapView)
        let c = mapView.convert(point, toCoordinateFrom: mapView)
        let newPlace = Place.newPlace(name: "")
        newPlace.locationActual = LocationCoordinate(lat: c.latitude, lon: c.longitude)
        let placeController = storyboard?.instantiateViewController(withIdentifier: "place") as! PlaceController
        placeController.place = newPlace
        navigationController?.pushViewController(placeController, animated: true)
    }

}

//MARK: - Working with map annotations
extension MapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            DispatchQueue.main.async {
                mapView.setRegion(MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000), animated: true)
            }
            return nil
        }
        
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        pin.animatesDrop = true
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.detailDisclosure)
        
        return pin
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let selectedPlace = (view.annotation as! PlaceAnnotation).place
        let placeController = storyboard?.instantiateViewController(withIdentifier: "place") as! PlaceController
        placeController.place = selectedPlace
        navigationController?.pushViewController(placeController, animated: true)
    }
    
}
