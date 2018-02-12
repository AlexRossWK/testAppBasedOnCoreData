//
//  Client+CoreDataClass.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 06.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//
//

import Foundation
import CoreData
//NSEntityDescription — это объект, который содержит описание нашей сущности. Все то, что мы сделали с сущностью в Редакторе модели данных (атрибуты, взаимосвязи, правила удаления и прочее), содержится в этом объекте. Единственное, что мы будем делать с ним — получать его и передавать куда-то в качестве параметра
@objc(Client)
public class Client: NSManagedObject {

    convenience init() {
        // //Сначала мы получаем описание сущности (entityDescription), передав в соответствующий конструктор строку с именем нужной нам сущности и ссылку на контекст. Контекст связан с координатором постоянного хранилища, а координатор связан с объекутной моделью данных, где и будет произведен поиск сущности по указанному имени.
        let entity = CoreDataManager.shared.entityForName(entityName: "Client")
        
        //Создаем сам управляемый объект (managedObject)
        self.init(entity: entity, insertInto: CoreDataManager.shared.managedObjectContext)
    }
}
