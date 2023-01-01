//
//  listVC.swift
//  Map App
//
//  Created by Doruk Özdemir on 31.12.2022.
//

import UIKit
import CoreData
import CoreLocation


class listVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var list: UITableView!
   
    var locs:[NSManagedObject] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = list.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! customViewCell
        
        
        cell.name.text = locs[indexPath.row].value(forKey: "name") as? String
        cell.note.text = locs[indexPath.row].value(forKey: "note") as? String

    
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: locs[indexPath.row].value(forKey: "latitude") as! CLLocationDegrees, longitude: locs[indexPath.row].value(forKey: "longitude") as! CLLocationDegrees)) { (placemarks, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            if let placemarks = placemarks, let placemark = placemarks.first {
                if let city = placemark.locality {
                    cell.city.text = city
                }
            }
        }
        
        
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        list.dataSource = self
        list.delegate = self
    
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Places")
        
        do {
            locs = try managedObjectContext.fetch(fetchRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        
        
        
        
       
    }
    



}
