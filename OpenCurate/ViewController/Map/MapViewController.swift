//
//  MapViewController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 9/5/2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy =  kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        
        if let coor = mapView.userLocation.location?.coordinate {
            mapView.setCenter(coor, animated: true)
        }

        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Update region on map view load and zoom in to current location
        // Reference to retrieving user current location:
        // https://stackoverflow.com/questions/25449469/show-current-location-and-update-location-in-mkmapview-in-swift
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        mapView.mapType = MKMapType.standard
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
        
        // Create annotation for user's current location
        let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        annotation.title = "Your Location"
        mapView.addAnnotation(annotation)
        
        showArtGalleries()
        
    }
    
    
    func showArtGalleries(){
        // Reference for location of interest
        // https://johncodeos.com/how-to-display-location-and-routes-with-corelocation-mapkit-using-swift/
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "art gallery"
        searchRequest.region = mapView.region
        searchRequest.resultTypes = [.pointOfInterest, .address]
        
        let search = MKLocalSearch(request: searchRequest)
        search.start{ response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "No error specified").")
                return
            }
            // Create annotation for every map item
            for mapItem in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                
                annotation.title = mapItem.name
                annotation.subtitle = mapItem.phoneNumber
                
                self.mapView.addAnnotation(annotation)
            }
            self.mapView.setRegion(response.boundingRegion, animated: true)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Reference for MapView annotations
        // https://johncodeos.com/how-to-display-location-and-routes-with-corelocation-mapkit-using-swift/
        
        let id = MKMapViewDefaultAnnotationViewReuseIdentifier
        
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView {
            
            if annotation.title == "Your Location" {
                view.titleVisibility = .visible
                view.markerTintColor = .link
                view.glyphImage = UIImage(systemName: "location.circle.fill")
                view.glyphTintColor = .white
                return view
            }
            
            else {
                view.titleVisibility = .visible
                view.subtitleVisibility = .visible
                view.markerTintColor = .systemOrange
                view.glyphImage = UIImage(systemName: "photo")
                view.glyphTintColor = .white
                return view
            }
        }
        
        return nil
    }
    
}
