//
//  ViewController.swift
//  Map App
//
//  Created by Doruk Özdemir on 28.12.2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var locManager = CLLocationManager()
   
    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        
        let gesRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRec: )))
        gesRecognizer.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(gesRecognizer)
    }
    
    @objc func chooseLocation(gestureRec:UILongPressGestureRecognizer){
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()

        let alert = UIAlertController(title: "Enter location name", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in textField.placeholder = "Name" }
        alert.addTextField { (textField) in textField.placeholder = "Note" }

            
            let touchedPoint = gestureRec.location(in: self.mapView)
            let touchedCoordinates = mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            let anot = MKPointAnnotation()
            anot.coordinate = touchedCoordinates
            
            self.mapView.addAnnotation(anot)
        if gestureRec.state == .began{
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                
                let nameField = alert.textFields![0] as UITextField
                let note = alert.textFields![1] as UITextField
                
                anot.title = nameField.text
                anot.subtitle = note.text
                
            })
            present(alert, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    var onoff = true
    
    @IBAction func press(_ sender: Any) {
        if onoff == true{
            self.locManager.startUpdatingLocation()
            button.setTitle("Tracking On", for: .normal)
            onoff = false
        }
        else{
            self.locManager.stopUpdatingLocation()
            button.setTitle("Tracking Off", for: .normal)
            onoff = true
        }
    }
}

