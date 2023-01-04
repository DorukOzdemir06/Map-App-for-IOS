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
    var managedObjectContext:NSManagedObjectContext?
    var fetchRequest:NSFetchRequest<NSManagedObject>?
    var locs:[NSManagedObject] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = list.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! customViewCell
        
        cell.name.text = locs[indexPath.row].value(forKey: "name") as? String
        cell.note.text = locs[indexPath.row].value(forKey: "note") as? String
        cell.city.text = locs[indexPath.row].value(forKey: "city") as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = locs[indexPath.row].value(forKey: "id") as? UUID
        NotificationCenter.default.post(name: NSNotification.Name("goLocation"), object: id)
        navigationController?.popViewController(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            // Delete the item
            var i = 0
            while i < locs.count {
                
                if i == indexPath.row{
                    managedObjectContext!.delete(locs[indexPath.row])
                    locs.remove(at: indexPath.row)
                    do{
                        try managedObjectContext!.save()
                    }
                    catch{print("error")}
                    self.list.reloadData()
                    break
                }
                i += 1
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        list.dataSource = self
        list.delegate = self
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Places")
        
        do {
            locs = try managedObjectContext!.fetch(fetchRequest!)
        } catch
            let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }

}
