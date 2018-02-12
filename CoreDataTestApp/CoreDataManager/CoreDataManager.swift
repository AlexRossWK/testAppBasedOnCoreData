//
//  CoreDataManager.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 06.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//

import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    //URL к пути, где хранятся все файлы приложения. По умолчанию, это Document Directory.
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    //Инициализируем путь к модели (имя forResource должно совпадать с моделью .xсdatamodeld)
    //Получаем из сборки приложения файл  с расширением momd и создаем на основании его объектную модель данных
    //Файл с расширением xdatamodel — это наша модель данных Core Data, которая при компиляции проекта включается в файл-сборку приложения с расширением momd.
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "CoreDataTestApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    //Объект координатора
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator =
    {
        objc_sync_enter ( self )
        //Создаем координатор постоянного хранилища
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        //Определяем, где именно должны храниться данные.
        let url = self.applicationDocumentsDirectory.appendingPathComponent("CoreDataTestApp.sqlite")
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            //Подключаем само хранилище
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil )
        } catch {
        }
        objc_sync_exit ( self )
        
        return coordinator
    }()

    //Объект контекста (главного)
     lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        //Создаем новый контекст управляемого объекта и присваиваем ему ссылку на наш координатор постоянного хранилища, с помощью которого он и будет читать и писать необходимые нам данные
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    //Вспомогательный функция для удобства сохранения контекста. Смысл — запись данных происходит только в том случаем, если они действительно были изменены.
    //Важно, что фактическая запись в хранилище будет выполнена только при явном вызове функции сохранения контекста.
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let error = error as Error
                NSLog("Unresolved error \(error)")
                abort()
            }
        }
    }
    
    //Функция, возвращающая описание сущности
    func entityForName(entityName: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)!
    }
    
    
    //NSFetchedResultsController не только возвращает массив нужных нам объектов в момент запроса(как делает NSFetchRequest), но и продолжает следить за всеми записями: если какая-то запись измениться — он нам сообщит об этом, если какие-нибудь записи подгрузятся в фоне через другой управляемый контекст — он нам тоже сообщит об этом. Нам останется только обработать это событие.
    func fetchedResultsController(entityName: String, keyForSort: String) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        //Метод сортировки
        let sortDescriptor = NSSortDescriptor(key: keyForSort, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.shared.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }
    
    
}
