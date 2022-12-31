//
//  listVC.swift
//  Map App
//
//  Created by Doruk Özdemir on 31.12.2022.
//

import UIKit
import CoreData

class listVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    var locs:[NSManagedObject] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell ()
     
        var content = cell.defaultContentConfiguration ()
        content.text = locs[indexPath.row].value(forKey: "name") as? String
        
        
        cell.contentConfiguration = content
        return cell
    }
    
    
    @IBOutlet weak var list: UITableView!
    

    
    
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
        print(locs.count)
      
    }
    



}
