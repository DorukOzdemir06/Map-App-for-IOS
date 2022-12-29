//
//  ViewController.swift
//  Map App
//
//  Created by Doruk Özdemir on 28.12.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var locManager = CLLocationManager()
    var alert = UIAlertController()
    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @IBOutlet weak var button: UIButton!
    var anot = MKPointAnnotation()
    
    
    func saveLocation(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(UUID(), forKey: "id")
        newPlace.setValue(self.anot.title, forKey: "name")
        newPlace.setValue(self.anot.subtitle, forKey: "note")
        newPlace.setValue(self.anot.coordinate.longitude, forKey: "longitude")
        newPlace.setValue(self.anot.coordinate.latitude, forKey: "latitude")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        alert = UIAlertController(title: "Enter location name", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in textField.placeholder = "Name" }
        alert.addTextField { (textField) in textField.placeholder = "Note" }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            
            let nameField = self.alert.textFields![0] as UITextField
            let note = self.alert.textFields![1] as UITextField
            
            self.anot.title = nameField.text
            self.anot.subtitle = note.text
            self.saveLocation()
            
            nameField.text = ""
            note.text = ""
        })
        mapView.delegate = self
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        
        let gesRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRec: )))
        gesRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(gesRecognizer)
    }
    
    
    @objc func chooseLocation(gestureRec:UILongPressGestureRecognizer){
        if gestureRec.state == .began{
            present(alert, animated: true)
            impactFeedbackGenerator.impactOccurred()
                        
            let touchedPoint = gestureRec.location(in: self.mapView)
            let touchedCoordinates = mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            anot = MKPointAnnotation()
            self.anot.coordinate = touchedCoordinates
            self.mapView.addAnnotation(self.anot)
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

