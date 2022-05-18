//
//  UploadSelectViewController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 18/5/2022.
//

import UIKit

class UploadSelectViewController: UIViewController {

    var uploadImage: UploadImage?
    
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var imageTitleLabel: UILabel!
    @IBOutlet weak var artistUsernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadImageView.image = UIImage(data: (uploadImage?.image)!)
        uploadImageView.enableZoom()
        
        imageTitleLabel.text = String((uploadImage?.storageLink)!)
        
        let username = uploadImage?.artistName ?? "N/A"
        artistUsernameLabel.text = username
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
