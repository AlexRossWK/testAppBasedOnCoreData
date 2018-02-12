//
//  Order+CoreDataClass.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 06.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Order)
public class Order: NSManagedObject {

    convenience init() {
        // //Сначала мы получаем описание сущности (entityDescription), передав в соответствующий конструктор строку с именем нужной нам сущности и ссылку на контекст. Контекст связан с координатором постоянного хранилища, а координатор связан с объекутной моделью данных, где и будет произведен поиск сущности по указанному имени.
        let entity = CoreDataManager.shared.entityForName(entityName: "Order")
        
        //Создаем сам управляемый объект (managedObject)
        self.init(entity: entity, insertInto: CoreDataManager.shared.managedObjectContext)

        
    }
    
    //Функция класса будет возвращать табличную часть DocumentVC в виде NSFetchedResultsController
   class func getRowsOfOrder(order: Order) -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RowOfOrder")
        //Ставим сортировку по service.name
        let sortDescriptor = NSSortDescriptor(key: "service.denomination", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "%K == %@", "order", order)
        fetchRequest.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.shared.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }
    
}
