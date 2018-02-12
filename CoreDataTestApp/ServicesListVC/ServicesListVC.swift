//
//  ServicesListVC.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 07.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//

import UIKit
import CoreData
class ServicesListVC: UIViewController {

    
    //Чтобы реализовать захват контекста в DocumentVC
    typealias Select = (Service?) -> ()
    //Если следующая переменная не определена — то список работает как обычно, в режиме добавления и редактирования данных, если определена — значит список был вызван из DocumetVC для выбора cервиса.
    var didSelect: Select?
    
    var fetchedResultsController = CoreDataManager.shared.fetchedResultsController(entityName: "Service", keyForSort: "denomination")
    
    let serviceCellReuseIdentifier = "servicesCell"
    
    @IBOutlet weak var servicesTableView: UITableView!



}

//Mark: - View Loads
extension ServicesListVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController.delegate = self
        
        do { try fetchedResultsController.performFetch() } catch { print(error) }
    }
}

//Mark: - table view delegate and dataSource methods
extension ServicesListVC: UITableViewDelegate, UITableViewDataSource {
    
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
        
        let service = fetchedResultsController.object(at: indexPath) as! Service
        let cell = tableView.dequeueReusableCell(withIdentifier: serviceCellReuseIdentifier, for: indexPath) as! ServicesCell
        cell.serviceLabel.text = service.denomination
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sourceView = tableView.cellForRow(at: indexPath)!
        let from = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
        let service = fetchedResultsController.object(at: indexPath) as? Service
        if let diddSelect = self.didSelect {
            diddSelect(service)
            navigationController?.popViewController(animated: true)
        } else {
            presentPOPServiceVC(sourceView: sourceView, from: from, service: service)
        }
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let managedObject = fetchedResultsController.object(at: indexPath) as! NSManagedObject
            CoreDataManager.shared.managedObjectContext.delete(managedObject)
            CoreDataManager.shared.saveContext()
        }
    }
    
    
}


//MARK: - Additional funcs
extension ServicesListVC {
    
    func presentPOPServiceVC(sourceView: UIView, from: CGRect, service: Service?) {
        guard let popServiceVC = storyboard?.instantiateViewController(withIdentifier: "popVCService") as! POPServiceVC? else {return}
        
        if service != nil {
            popServiceVC.service = service
        }
        
        popServiceVC.modalPresentationStyle = .popover
        let popOverServiceVC = popServiceVC.popoverPresentationController
        popOverServiceVC?.delegate = self
        //Родительский слой POPVC
        popOverServiceVC?.sourceView = sourceView
        //Определяем откуда будет идти стрелка POPVC
        popOverServiceVC?.sourceRect = from
        //Размер
        popServiceVC.preferredContentSize = CGSize(width: 300, height: 170)
        self.present(popServiceVC, animated: true, completion: nil)
    }
    
}

//MARK: UIPopoverPresentationController Delegate methods
extension ServicesListVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}



//MARK: - Add client button
extension ServicesListVC {
    @IBAction func addService(_ sender: UIBarButtonItem) {
        let sourceView = servicesTableView!
        presentPOPServiceVC(sourceView: sourceView, from: CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.minY, width: sourceView.bounds.midX + 110 , height: 0), service: nil)
    }
}

// Чтобы обновить таблицу при добавлении/изменении обектов используем NSFetchedResultsController , который знает, что изменения произошли
//MARK: NSFetchedResultsController Delegate methods
//Здесь мы получаем информацию о том, какой объект и как именно изменился, и, в зависимости от типа изменения, мы выполняем различные действия
extension ServicesListVC: NSFetchedResultsControllerDelegate {
    //Начало изменения данных
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        servicesTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        //Обновление - данные объекта изменились, получаем строку из нашего списка по указанному индексу и обновляем информацию о ней
        case .update:
            if let indexPath = indexPath {
                let service = fetchedResultsController.object(at: indexPath) as! Service
                let cell = servicesTableView.cellForRow(at: indexPath) as! ServicesCell
                cell.serviceLabel.text = service.denomination
            }
        //Добавление - вставляем новую строку по указанному индексу (строка добавится не просто в конец списка, а в свое место в списке в соответствии с заданной сортировкой)
        case .insert:
            if let indexPath = newIndexPath {
                servicesTableView.insertRows(at: [indexPath], with: .automatic)
            }
        //Перемещение - порядок строк изменился (например, Заказчика переименовали и он теперь располагается в соответствии с сортировкой в другом месте), удаляем строку оттуда, где она была и добавляем уже по новому индексу
        case .move:
            if let indexPath = indexPath {
                servicesTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                servicesTableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        //Удаление -  удаляем строку по указанному индексу.
        case .delete:
            if let indexPath = indexPath {
                servicesTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
        }
    }
    //Конец изменения данных
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        servicesTableView.endUpdates()
    }
    
}




