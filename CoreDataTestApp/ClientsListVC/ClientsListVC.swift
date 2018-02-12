//
//  ClientsListVC.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 06.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//

import UIKit
import CoreData

class ClientsListVC: UIViewController {
    
    //Чтобы реализовать захват контекста в DocumentVC
    typealias Select = (Client?) -> ()
    //Если следующая переменная не определена — то список работает как обычно, в режиме добавления и редактирования данных, если определена — значит список был вызван из DocumetVC для выбора клиента.
    var didSelect: Select?
    
    
    
    let clientsCellNib = UINib(nibName: "ClientsCell", bundle: nil)
    let clientsCellReuseIdentifier = "ClientsCell"
    
    var fetchedResultsController = CoreDataManager.shared.fetchedResultsController(entityName: "Client", keyForSort: "name")
    
    @IBOutlet weak var addButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var clientsTableView: UITableView!
}

//Mark: - View Loads
extension ClientsListVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCell(nib: clientsCellNib, reuseIdentifier: clientsCellReuseIdentifier)
        
        fetchedResultsController.delegate = self
        
        do { try fetchedResultsController.performFetch() } catch { print(error) }
        

    }
    
}


//Mark: - table view delegate and dataSource methods
extension ClientsListVC: UITableViewDelegate, UITableViewDataSource {
    
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
        
        let client = fetchedResultsController.object(at: indexPath) as! Client
        let cell = tableView.dequeueReusableCell(withIdentifier: clientsCellReuseIdentifier, for: indexPath) as! ClientsCell
        cell.nameLabel.text = client.name
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sourceView = tableView.cellForRow(at: indexPath)!
        let from = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
        let client = fetchedResultsController.object(at: indexPath) as? Client
        
        if let diddSelect = self.didSelect {
            diddSelect(client)
            navigationController?.popViewController(animated: true)
        } else {
            presentPOPClientVC(sourceView: sourceView, from: from, client: client)
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
extension ClientsListVC {
    func registerCell(nib: UINib, reuseIdentifier: String ){
        clientsTableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
}
    
    func presentPOPClientVC(sourceView: UIView, from: CGRect, client: Client?) {
        guard let popClientVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as! POPClientVC? else {return}
        
        if client != nil {
        popClientVC.client = client
        }
        
        popClientVC.modalPresentationStyle = .popover
        let popOverClientVC = popClientVC.popoverPresentationController
        popOverClientVC?.delegate = self
        //Родительский слой POPVC
        popOverClientVC?.sourceView = sourceView
        //Определяем откуда будет идти стрелка POPVC
        popOverClientVC?.sourceRect = from
        //Размер
        popClientVC.preferredContentSize = CGSize(width: 300, height: 170)
        self.present(popClientVC, animated: true, completion: nil)
    }
    
}

//MARK: UIPopoverPresentationController Delegate methods
extension ClientsListVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}



//MARK: - Add client button
extension ClientsListVC {
    @IBAction func addClient(_ sender: UIBarButtonItem) {
        let sourceView = clientsTableView!
        presentPOPClientVC(sourceView: sourceView, from: CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.minY, width: sourceView.bounds.midX + 110 , height: 0), client: nil)
    }
}

// Чтобы обновить таблицу при добавлении/изменении обектов используем NSFetchedResultsController , который знает, что изменения произошли
//MARK: NSFetchedResultsController Delegate methods
//Здесь мы получаем информацию о том, какой объект и как именно изменился, и, в зависимости от типа изменения, мы выполняем различные действия
extension ClientsListVC: NSFetchedResultsControllerDelegate {
    //Начало изменения данных
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        clientsTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        //Обновление - данные объекта изменились, получаем строку из нашего списка по указанному индексу и обновляем информацию о ней
        case .update:
            if let indexPath = indexPath {
                let client = fetchedResultsController.object(at: indexPath) as! Client
                let cell = clientsTableView.cellForRow(at: indexPath) as! ClientsCell
                cell.nameLabel.text = client.name
            }
            //Добавление - вставляем новую строку по указанному индексу (строка добавится не просто в конец списка, а в свое место в списке в соответствии с заданной сортировкой)
        case .insert:
            if let indexPath = newIndexPath {
                clientsTableView.insertRows(at: [indexPath], with: .automatic)
            }
            //Перемещение - порядок строк изменился (например, Заказчика переименовали и он теперь располагается в соответствии с сортировкой в другом месте), удаляем строку оттуда, где она была и добавляем уже по новому индексу
        case .move:
            if let indexPath = indexPath {
                clientsTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                clientsTableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            //Удаление -  удаляем строку по указанному индексу.
        case .delete:
            if let indexPath = indexPath {
                clientsTableView.deleteRows(at: [indexPath], with: .automatic)
            }

        }
    }
    //Конец изменения данных
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        clientsTableView.endUpdates()
    }
    
}
    



