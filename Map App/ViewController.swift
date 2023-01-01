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
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var button: UIButton!
    var anot = Anot( id: nil, location: MKPointAnnotation())
    var touchedPoint:CGPoint = CGPoint()
    var touchedCoordinates:CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    private func loadLocations(){
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Places")
        
        do {
            let objects = try managedObjectContext.fetch(fetchRequest)
            
            for object in objects {
                self.anot = Anot( id: object.value(forKey: "id") as? UUID, location: MKPointAnnotation())
                self.anot.location.title = object.value(forKey: "name") as? String
                self.anot.location.subtitle = object.value(forKey: "note") as? String
                self.anot.location.coordinate.longitude = object.value(forKey: "longitude") as! Double
                self.anot.location.coordinate.latitude = object.value(forKey: "latitude") as! Double
                self.mapView.addAnnotation(anot.location)
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func saveLocation(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        let Id = UUID()
        
        newPlace.setValue(Id, forKey: "id")
        self.anot.id = Id;
        newPlace.setValue(self.anot.location.title, forKey: "name")
        newPlace.setValue(self.anot.location.subtitle, forKey: "note")
        newPlace.setValue(self.anot.location.coordinate.longitude, forKey: "longitude")
        newPlace.setValue(self.anot.location.coordinate.latitude, forKey: "latitude")
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: self.anot.location.coordinate.latitude, longitude:self.anot.location.coordinate.longitude)) { (placemarks, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            if let placemarks = placemarks, let placemark = placemarks.first {
                if let city = placemark.locality {
                    newPlace.setValue(city, forKey: "city")
                }
            }
        }
        
        do{
            try context.save()

        }
        catch{
            print("db save error")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadLocations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        loadLocations()
        alert = UIAlertController(title: "Enter location name", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in textField.placeholder = "Name" }
        alert.addTextField { (textField) in textField.placeholder = "Note" }
        let nameField = self.alert.textFields![0] as UITextField
        let note = self.alert.textFields![1] as UITextField
        
        
        alert.addAction(UIAlertAction(title: "Add", style: .cancel) { _ in
            self.anot = Anot( id: nil, location: MKPointAnnotation())
            self.anot.location.coordinate = self.touchedCoordinates
            self.mapView.addAnnotation(self.anot.location)
            self.anot.location.title = nameField.text
            self.anot.location.subtitle = note.text
            self.saveLocation()
            
            nameField.text = ""
            note.text = ""
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive) { _ in
            nameField.text = ""
            note.text = ""
        })
        
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        
        let gesRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRec: )))
        gesRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(gesRecognizer)
        
    }
    
    
    @objc func chooseLocation(gestureRec:UILongPressGestureRecognizer){
        if gestureRec.state == .began{
            touchedPoint = gestureRec.location(in: self.mapView)
            touchedCoordinates = mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            impactFeedbackGenerator.impactOccurred()
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
    
    
    @IBAction func listButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "toList", sender: nil)
    }
    
    
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

