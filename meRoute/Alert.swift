//
//  Alert.swift
//  meRoute
//
//  Created by Александр Прайд on 27.05.2022.
//

import UIKit

extension UIViewController {
    
    func alertAddAddress(title: String, placeholder: String, complitionHandler: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertOK = UIAlertAction(title: "OK", style: .default) { (action) in
            
            let textFieldText = alertController.textFields?.first
            guard let text = textFieldText?.text else { return }
            complitionHandler(text)
        }
        
        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { (_) in
            
        }
        
        alertController.addTextField { (textF) in
            textF.placeholder = placeholder
        }
        
        alertController.addAction(alertOK)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func alertError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOK = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(alertOK)
        
        present(alertController, animated: true, completion: nil)
    }
}
