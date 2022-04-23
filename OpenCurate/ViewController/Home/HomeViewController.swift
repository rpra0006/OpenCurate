//
//  HomeViewController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 22/4/2022.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var logoButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoButton.image = UIImage(named: "OpenCurateLogo")?.withRenderingMode(.alwaysOriginal)
        
        //navigationController?.navigationBar.barTintColor = UIColor.white
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

}
