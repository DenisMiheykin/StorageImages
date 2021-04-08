import UIKit
import SwiftyKeychainKit

class StartViewController: UIViewController {

    // MARK: - outlets
    @IBOutlet weak var passwordTF: UITextField!
    
    // MARK: - let
    let keychain = Keychain(service: "com.denisMikheykin.StorageImages")
    let accessTokenKey = KeychainKey<String>(key: "accessToken")
    
    // MARK: - IBActions
    @IBAction func singInButtonPressed(_ sender: UIButton) {
        if self.checkPassword() {
            self.singIn()
        } else {
            self.showAlert(title: "Fail", message: "Passwords do not match")
        }
    }
    
    // MARK: - flow funcs
    func checkPassword() -> Bool {
        guard let value = self.passwordTF.text else {
            return false
        }
        if value.isEmpty {
            return false
        }
        
        if let password = try? self.keychain.get(self.accessTokenKey) {
            return self.passwordTF.text == password
        } else {
            self.showAlertCreatePassword()
            return false
        }
    }
    
    func singIn() {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "EditorViewController") as? EditorViewController else {
            return
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - extension
extension StartViewController {
    
    func showAlertCreatePassword() {
        
        let alert = UIAlertController(title: "Registration", message: "Repeat your password to complete registration", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Repeat password"
            textField.isSecureTextEntry = true
        }
        
        let cancelAction  = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let action  = UIAlertAction(title: "OK", style: .default) { [weak alert] (_) in
            if alert?.textFields?.first?.text?.isEmpty ?? true {
                self.showAlert(title: "Fail", message: "Passwords do not match")
            } else {
                if self.passwordTF.text ?? "" == alert?.textFields?.first?.text {
                    try? self.keychain.set(self.passwordTF.text!, for: self.accessTokenKey)
                    self.showAlert(title: "Great", message: "Successful registration")
                } else {
                    self.showAlert(title: "Fail", message: "Passwords do not match")
                }
            }
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showAlert(title: String, message: String, preferredStyle: UIAlertController.Style = .alert, actionTitle: String = "OK", style: UIAlertAction.Style = .default, handler: @escaping ((UIAlertAction) -> Void)) {
        
        showAlert(title: title, message: message, preferredStyle: preferredStyle, actions: [(actionTitle, style, handler)])
        
    }
    
    func showAlert(title: String, message: String, preferredStyle: UIAlertController.Style = .alert, actions: [(title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void))]) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        for element in actions {
            alert.addAction(UIAlertAction(title: element.title, style: element.style, handler: element.handler))
        }
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showAlert(title: String, message: String) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
}
