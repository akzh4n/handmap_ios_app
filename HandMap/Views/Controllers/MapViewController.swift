//
//  MapViewController.swift
//  HandMap
//
//  Created by Акжан Калиматов on 06.09.2022.
//


// Connecting MapKit

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {

    
    

    
    @IBOutlet weak var mainMapView: MKMapView!
    
    
    
    // Here map settings
  
    fileprivate var searchController: UISearchController!
    fileprivate var localSearchRequest: MKLocalSearch.Request!
    fileprivate var localSearch: MKLocalSearch!
    fileprivate var localSearchResponse: MKLocalSearch.Response!
    
    // There are map - variables
    
    fileprivate var annotation: MKAnnotation!
    fileprivate var locationManager: CLLocationManager!
    fileprivate var isCurrentLocation: Bool = false


    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainMapView.delegate = self
        
        // Change map view
        
        mainMapView.mapType = .satellite
  
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.layer.cornerRadius = 10
        self.navigationController?.navigationBar.clipsToBounds = true
        
    }
    
   
    
    // To determine the exact position of the user on the map
    
    @IBAction func currentLocationBtn(_ sender: Any) {
        if (CLLocationManager.locationServicesEnabled()) {
            if locationManager == nil {
                locationManager = CLLocationManager()
            }
            locationManager?.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            isCurrentLocation = true
        }
    }
    
    
    // To search some place from the map
    
    @IBAction func searchButtonAction(_ button: UIBarButtonItem) {
        if searchController == nil {
            searchController = UISearchController(searchResultsController: nil)
        }
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        if self.mainMapView.annotations.count != 0 {
            annotation = self.mainMapView.annotations[0]
            self.mainMapView.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { [weak self] (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil {
                let alertController = UIAlertController(title: "Error", message: "Place not found", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Try again", style: .default)
                alertController.addAction(okAction)
                return
            }
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = searchBar.text
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self!.mainMapView.centerCoordinate = pointAnnotation.coordinate
            self!.mainMapView.addAnnotation(pinAnnotationView.annotation!)
        }
    }
    

 

}


// Extension for Location Manage

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !isCurrentLocation {
            return
        }
        
        isCurrentLocation = false
        
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mainMapView.setRegion(region, animated: true)
        
        if self.mainMapView.annotations.count != 0 {
            annotation = self.mainMapView.annotations[0]
            self.mainMapView.removeAnnotation(annotation)
        }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = location!.coordinate
        pointAnnotation.title = ""
        mainMapView.addAnnotation(pointAnnotation)
    }
}
