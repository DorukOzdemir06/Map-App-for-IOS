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
    var alert:UIAlertController!
    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var button: UIButton!
    var anot = Anot( id: nil, location: MKPointAnnotation())
    var touchedPoint:CGPoint!
    var touchedCoordinates:CLLocationCoordinate2D!
    var con:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        con = appDelegate.persistentContainer.viewContext
        mapView.delegate = self
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        
        alert = UIAlertController(title: "Enter location attributes", message: nil, preferredStyle: .alert)
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
        mapView.mapType = .mutedStandard
        
        let gesRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRec: )))
        gesRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(gesRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadLocations()
        NotificationCenter.default.addObserver(self, selector: #selector(goLocation(_:)), name: NSNotification.Name(rawValue: "goLocation"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        do{
            try con.save()
        }
        catch{
            print("db save error")
        }
    }
    
    private func loadLocations(){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Places")
        
        do {
            let objects = try con.fetch(fetchRequest)
            
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
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: con)
        
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
            try con.save()
        }
        catch{
            print("db save error")
        }
    }
    
    @objc func goLocation(_ notification: Notification) {
        
        if let data = notification.object as? UUID {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            fetchRequest.predicate = NSPredicate(format: "id = %@", data as CVarArg)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let result = try con.fetch(fetchRequest)
                let res = result[0] as? NSManagedObject
                
                let location = CLLocationCoordinate2D(latitude: res?.value(forKey: "latitude") as! CLLocationDegrees, longitude: res?.value(forKey: "longitude") as! CLLocationDegrees)
                let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
                let region = MKCoordinateRegion(center: location, span: span)
                mapView.setRegion(region, animated: true)
            }
            catch{
                print("error while go")
            }
        }
    }
    
    @objc func chooseLocation(gestureRec:UILongPressGestureRecognizer){
        if gestureRec.state == .began{
            touchedPoint = gestureRec.location(in: self.mapView)
            touchedCoordinates = mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            impactFeedbackGenerator.impactOccurred()
            present(alert, animated: true)
        }
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func listButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "toList", sender: nil)
    }
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let anotId = "Anot"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: anotId)
        
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: anotId)
            pinView?.canShowCallout = true
            
            let navButton = UIButton(type: .custom)
            navButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            navButton.setImage(UIImage(named: "goImage"), for: .normal)
            let delButton = UIButton(type: .custom)
            delButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            delButton.setImage(UIImage(named: "deleteImage"), for: .normal)
            
            pinView?.rightCalloutAccessoryView = navButton
            pinView?.leftCalloutAccessoryView = delButton
            
        }
        else{
            pinView?.annotation = annotation
        }
      
        
        return pinView
    }
}

