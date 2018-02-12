//
//  RowOfOrderVC.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 07.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//

import UIKit

class RowOfOrderVC: UIViewController {

    var rowOfOrder: RowOfOrder?
    
    @IBOutlet weak var serviceTextField: UITextField!
    
    @IBOutlet weak var sumTextField: UITextField!
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        saveRow()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chooseService(_ sender: UIButton) {
        performSegue(withIdentifier: "rowOfOrderToServices", sender: nil)
    }
}


//MARK: - View Loads
extension RowOfOrderVC{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let rowOfOrder = rowOfOrder {
            serviceTextField.text = rowOfOrder.service?.denomination
            sumTextField.text = String(rowOfOrder.sum)
        } else {
            rowOfOrder = RowOfOrder()
        }
        
    }
}


//MARK: - Additional funcs
extension RowOfOrderVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rowOfOrderToServices" {
            let newVC = segue.destination as! ServicesListVC
            newVC.didSelect = { [weak self] (service) in
                if let service = service {
                    self?.rowOfOrder!.service = service
                    self?.serviceTextField.text = service.denomination
                }
            }
    }
}
    
    func saveRow() {
        if let rowOfOrder = rowOfOrder {
            rowOfOrder.sum = Float(sumTextField.text!)!
            CoreDataManager.shared.saveContext()
        }
    }
    
}

//MARK: - Buttons Actions
extension RowOfOrder {
   
}
