//
//  Service+CoreDataClass.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 06.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Service)
public class Service: NSManagedObject {

    convenience init() {
        // //Сначала мы получаем описание сущности (entityDescription), передав в соответствующий конструктор строку с именем нужной нам сущности и ссылку на контекст. Контекст связан с координатором постоянного хранилища, а координатор связан с объекутной моделью данных, где и будет произведен поиск сущности по указанному имени.
        let entity = CoreDataManager.shared.entityForName(entityName: "Service")
        
        //Создаем сам управляемый объект (managedObject)
        self.init(entity: entity, insertInto: CoreDataManager.shared.managedObjectContext)
    }
    
}
