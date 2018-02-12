//
//  DocumentVC.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 07.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//

import UIKit
import CoreData

class DocumentVC: UIViewController {

    var order: Order?
    //Объявим переменную, которая будет содержать табличную часть и инициализировать ее после инициализации самого документа
    var tableViewPart: NSFetchedResultsController<NSFetchRequestResult>?

   
    
    @IBOutlet weak var switchPaid: UISwitch!
    @IBOutlet weak var sitchMade: UISwitch!
    @IBOutlet weak var orderTableView: UITableView!
    @IBOutlet weak var clientTextField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    

    

}

//MARK: - View Loads
extension DocumentVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //В данном случае, для разнообразия создадим объект документа здесь
        if order == nil {
            order = Order()
            //Сразу присвоим ему текущую дату
            order?.date = NSDate()
        }
        if let order = order {
            datePicker.date = order.date! as Date
            sitchMade.isOn = order.made
            switchPaid.isOn = order.paid
            clientTextField.text = order.client?.name
            
            
            tableViewPart = Order.getRowsOfOrder(order: order)
            
            tableViewPart!.delegate = self

            
            do {
                try tableViewPart!.performFetch()
            } catch {
                print(error)
            }
        }
            
        }
        
        
    }


//MARK: - Buttons Action
extension DocumentVC {
    @IBAction func save(_ sender: UIButton) {
        if saveOrder() {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func chooseClientAction(_ sender: UIButton) {
        performSegue(withIdentifier: "orderToClients", sender: nil)
    }
    
    
    @IBAction func addRowAction(_ sender: UIButton) {
        if let order = order {
            let newRowOfOrder = RowOfOrder()
            newRowOfOrder.order = order
            performSegue(withIdentifier: "orderToRowOfOrder", sender: newRowOfOrder)
        }
    }
    
}


//MARK: - Additional funcs
extension DocumentVC {
    func saveOrder() -> Bool {
        if let order = order {
            order.date = datePicker.date as NSDate
            order.made = sitchMade.isOn
            order.paid = switchPaid.isOn
            CoreDataManager.shared.saveContext()
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "orderToClients":
            let newVC = segue.destination as! ClientsListVC
            //Реализуем замыкание
            newVC.didSelect = { [weak self] (client) in
                if let client = client {
                    self?.order?.client = client
                    self?.clientTextField.text = client.name!
                }
            }
        case "orderToRowOfOrder":
            let newVC = segue.destination as! RowOfOrderVC
            newVC.rowOfOrder = sender as? RowOfOrder
        default:
            break
        }
    }
    
    
}

//MARK:- Table view delegate and dataSource methods
extension DocumentVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = tableViewPart?.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowOfOrder = tableViewPart?.object(at: indexPath) as! RowOfOrder
        let cell = UITableViewCell()
        let nameOfService = (rowOfOrder.service == nil) ? "noname" : (rowOfOrder.service!.denomination!)
        cell.textLabel?.text = nameOfService + " - " + String(rowOfOrder.sum)
        return cell
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let managedObject = tableViewPart?.object(at: indexPath) as! NSManagedObject
            CoreDataManager.shared.managedObjectContext.delete(managedObject)
            CoreDataManager.shared.saveContext()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowOfOrder = tableViewPart?.object(at: indexPath) as! RowOfOrder
        performSegue(withIdentifier: "orderToRowOfOrder", sender: rowOfOrder)
    }
    
}

// Чтобы обновить таблицу при добавлении/изменении обектов используем NSFetchedResultsController , который знает, что изменения произошли
//MARK: NSFetchedResultsController Delegate methods
//Здесь мы получаем информацию о том, какой объект и как именно изменился, и, в зависимости от типа изменения, мы выполняем различные действия
extension DocumentVC: NSFetchedResultsControllerDelegate {
    //Начало изменения данных
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        orderTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        //Обновление - данные объекта изменились, получаем строку из нашего списка по указанному индексу и обновляем информацию о ней
        case .update:
            if let indexPath = indexPath {
                let rowOfOrder = tableViewPart?.object(at: indexPath) as! RowOfOrder
                let cell = orderTableView.cellForRow(at: indexPath)!
                let nameOfService = (rowOfOrder.service == nil) ? "noname" : (rowOfOrder.service!.denomination!)
                cell.textLabel?.text = nameOfService + " - " + String(rowOfOrder.sum)
            }
        //Добавление - вставляем новую строку по указанному индексу (строка добавится не просто в конец списка, а в свое место в списке в соответствии с заданной сортировкой)
        case .insert:
            if let indexPath = newIndexPath {
                orderTableView.insertRows(at: [indexPath], with: .automatic)
            }
        //Перемещение - порядок строк изменился (например, Заказчика переименовали и он теперь располагается в соответствии с сортировкой в другом месте), удаляем строку оттуда, где она была и добавляем уже по новому индексу
        case .move:
            if let indexPath = indexPath {
                orderTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                orderTableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        //Удаление -  удаляем строку по указанному индексу.
        case .delete:
            if let indexPath = indexPath {
                orderTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
        }
    }
    //Конец изменения данных
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        orderTableView.endUpdates()
    }
    
}
