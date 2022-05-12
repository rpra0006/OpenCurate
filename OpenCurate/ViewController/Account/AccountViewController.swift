//
//  UploadViewController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 11/5/2022.
//

import UIKit

class AccountViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func logoutButton(_ sender: Any) {
        
        databaseController?.signOut(){
            [weak self] result in
                switch result {
                    case .success(let p):
                    DispatchQueue.main.async {
                        self!.performSegue(withIdentifier: "logoutSegue", sender: sender)
                        print("Sign out successful")
                    }
                    case .failure(let error):
                    DispatchQueue.main.async {
                        self!.displayMessage(title: "Error", message: "Unable to signout.")
                    }
                }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
