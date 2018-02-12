//
//  ReportVC.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 12.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//

import UIKit
import CoreData

class ReportVC: UIViewController {

    @IBOutlet weak var reportTableView: UITableView!
    
       var report: [Order]?
    
    
    
    var fetchRequest: NSFetchRequest<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Order")
        
        // Можно несколько сортировок
        let sortDescriptor1 = NSSortDescriptor(key: "date", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "client.name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        //NSPredicate — для задания различных условий отбора
        //"%K" — означает имя поля (свойства) объекта, "%@" — значение этого поля.
        //Можно использовать не только операцию ==, но <, >=, != и так далее. Также можно использовать ключевые слова, такие как CONTAINS, LIKE, MATCHES, BEGINSWITH, ENDSWITH, а также AND и OR
//        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", "made", true, "paid", false)
//        fetchRequest.predicate = predicate
        
        return fetchRequest
    }()
    


}


//MARK: - View Loads
extension ReportVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {report = try CoreDataManager.shared.managedObjectContext.fetch(fetchRequest) as? [Order]} catch {print(error)}
        
    }
}


//MARK: - Table View delegates and dataSource methods
extension ReportVC:
UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let report = report {
            return report.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if let report = report {
            let order = report[indexPath.row]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            let nameOfClient = (order.client == nil) ? "noname" : (order.client!.name!)
            cell.textLabel?.text = formatter.string(from: order.date! as Date) + "\t" + nameOfClient
        }
        
        return cell
    }
    

}
