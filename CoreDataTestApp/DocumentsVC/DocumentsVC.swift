//
//  DocumentsVC.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 07.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//

import UIKit
import CoreData

class DocumentsVC: UIViewController {

    @IBOutlet weak var documentTableView: UITableView!
    
    var documentCellReuseIdentifier = ""
    
     var fetchedResultsController = CoreDataManager.shared.fetchedResultsController(entityName: "Order", keyForSort: "date")
 


}

//MARK: - View loads
extension DocumentsVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController.delegate = self
        
         do { try fetchedResultsController.performFetch() } catch { print(error) }
    }
}

//MARK: - Add client button
extension DocumentsVC {
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "OrdersToOrder", sender: self)
    }
}


//MARK: - Additional funcs
extension DocumentsVC {
    func configureCell(cell: UITableViewCell, order: Order) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy"
        let nameOfClient = (order.client == nil) ? "Error" : (order.client!.name!)
        cell.textLabel?.text = formatter.string(from: order.date! as Date) + "\t" + nameOfClient
    }
    
     func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OrdersToOrder" {
            let newVC = segue.destination as! DocumentVC
            newVC.order = sender as? Order
        }
    }
}


//Mark: - table view delegate and dataSource methods
extension DocumentsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let order = fetchedResultsController.object(at: indexPath) as! Order
        let cell = UITableViewCell()
        configureCell(cell: cell, order: order)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = fetchedResultsController.object(at: indexPath) as? Order
        performSegue(withIdentifier: "OrdersToOrder", sender: order)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let managedObject = fetchedResultsController.object(at: indexPath) as! NSManagedObject
            CoreDataManager.shared.managedObjectContext.delete(managedObject)
            CoreDataManager.shared.saveContext()
        }
    }
    
    
}






// Чтобы обновить таблицу при добавлении/изменении обектов используем NSFetchedResultsController , который знает, что изменения произошли
//MARK: NSFetchedResultsController Delegate methods
//Здесь мы получаем информацию о том, какой объект и как именно изменился, и, в зависимости от типа изменения, мы выполняем различные действия
extension DocumentsVC: NSFetchedResultsControllerDelegate {
    //Начало изменения данных
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        documentTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        //Обновление - данные объекта изменились, получаем строку из нашего списка по указанному индексу и обновляем информацию о ней
        case .update:
            if let indexPath = indexPath {
                let order = fetchedResultsController.object(at: indexPath) as! Order
                let cell = documentTableView.cellForRow(at: indexPath)
                configureCell(cell: cell!, order: order)
            }
        //Добавление - вставляем новую строку по указанному индексу (строка добавится не просто в конец списка, а в свое место в списке в соответствии с заданной сортировкой)
        case .insert:
            if let indexPath = newIndexPath {
                documentTableView.insertRows(at: [indexPath], with: .automatic)
            }
        //Перемещение - порядок строк изменился (например, Заказчика переименовали и он теперь располагается в соответствии с сортировкой в другом месте), удаляем строку оттуда, где она была и добавляем уже по новому индексу
        case .move:
            if let indexPath = indexPath {
                documentTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                documentTableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        //Удаление -  удаляем строку по указанному индексу.
        case .delete:
            if let indexPath = indexPath {
                documentTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
        }
    }
    //Конец изменения данных
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        documentTableView.endUpdates()
    }
    
}


