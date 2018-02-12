//
//  POPClientVC.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 06.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//

import UIKit

class POPClientVC: UIViewController {
    
    var client: Client?

    
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var infoTextField: UITextField!
    

 
 
}


//Mark: - View loads
extension POPClientVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        if let client = client {
            nameTextField.text = client.name
            infoTextField.text = client.info
        }
    }
}


//Mark: - Buttons Action
extension POPClientVC {

    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)

    }
    
    @IBAction func save(_ sender: UIButton) {
        if saveCustomer() {
            dismiss(animated: true, completion: nil)
        }
    }



}


//Mark: - Additional funcs
extension POPClientVC {
    
    func saveCustomer() -> Bool {
        // Валидация обязательных полей
        if nameTextField.text!.isEmpty {
            let alert = UIAlertController(title: "Validation error", message: "Input the name of the Client!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        // Создаем объект клиента
        if client == nil {
            client = Client()
        }
        // Сохраняем объект (а точнее меняем атрибуты созданного объекта) в CoreData
        if let client = client {
            client.name = nameTextField.text
            client.info = infoTextField.text
            CoreDataManager.shared.saveContext()
        }
        return true
    }
    
}
