//
//  POPServiceVC.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 07.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//

import UIKit

class POPServiceVC: UIViewController {

    var service: Service?
    
    @IBOutlet weak var nameTexField: UITextField!
    @IBOutlet weak var infoTextField: UITextField!
    

}




//Mark: - View loads
extension POPServiceVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        if let service = service {
            nameTexField.text = service.denomination
            infoTextField.text = service.info
        }
    }
}


//Mark: - Buttons Action
extension POPServiceVC {
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)

    }
    @IBAction func saveAction(_ sender: UIButton) {
        if saveService() {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
}


//Mark: - Additional funcs
extension POPServiceVC {
    
    func saveService() -> Bool {
        // Валидация обязательных полей
        if nameTexField.text!.isEmpty {
            let alert = UIAlertController(title: "Validation error", message: "Input the name of the Service!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        // Создаем объект клиента
        if service == nil {
            service = Service()
        }
        // Сохраняем объект (а точнее меняем атрибуты созданного объекта) в CoreData
        if let service = service {
            service.denomination = nameTexField.text
            service.info = infoTextField.text
            CoreDataManager.shared.saveContext()
        }
        return true
    }
    
}
