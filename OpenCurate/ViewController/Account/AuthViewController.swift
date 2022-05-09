//
//  AuthViewController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 5/5/2022.
//

import UIKit

class AuthViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginAction(_ sender: Any) {
        performSegue(withIdentifier: "authSegue", sender: sender)
    }
    
    
    @IBAction func registerAction(_ sender: Any) {
        performSegue(withIdentifier: "authSegue", sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
    @IBAction func loginClicked(_ sender: Any) {
        
        if isValidAuth(emailTextField.text ?? "" , passwordTextField.text ?? ""){
            
            databaseController?.signIn(email: emailTextField.text!, password: passwordTextField.text!) { [weak self]result in
                switch result {
                    case .success(let p):
                    DispatchQueue.main.async {
                        self!.performSegue(withIdentifier: "authSegue", sender: sender)
                        print("Logged in")
                    }
                    case .failure(let error):
                    DispatchQueue.main.async {
                        self!.displayMessage(title: "Error", message: "Password and/or email is invalid. Please try again.")
                    }
                    
                }
                
            }


        }
        return
        
    }
    */
    
    /*
    @IBAction func registerClicked(_ sender: Any) {
     
     if isValidAuth(emailTextField.text ?? "", passwordTextField.text ?? ""){
         
         databaseController?.register(email: emailTextField.text!, password: passwordTextField.text!) { [weak self] result in
             switch result {
                 case .success(let p):
                 DispatchQueue.main.async {
                     self!.performSegue(withIdentifier: "authSegue", sender: sender)
                     print("Registration is succesfull ")
                 }
                 case .failure(let error):
                 DispatchQueue.main.async {
                     self!.displayMessage(title: "Error", message: "Email has already been used.")
                 }
                 
             }
         }

     }
     return
    }
    */

    func isValidAuth(_ email: String, _ password: String) -> Bool {
        
        let emailTest = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}")
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.[a-z]).{6,}$")
        
        if emailTest.evaluate(with: email){
            if passwordTest.evaluate(with: password){
                return true
            }
            displayMessage(title: "Error", message: "Password must be at least 6 characters long.")
            return false
        }
        displayMessage(title: "Error", message: "Please enter a valid email address.")
        return false
    }
    
}
