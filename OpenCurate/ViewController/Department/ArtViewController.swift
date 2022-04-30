//
//  ArtViewController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 30/4/2022.
//

import UIKit

class ArtViewController: UIViewController {
    
    
    @IBOutlet weak var artImage: UIImageView!
    var imgURL: URL?
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor), indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        indicator.startAnimating()
        renderImage()
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
    
    func renderImage() {
        
        guard let url = imgURL else {
            artImage.image = UIImage(named: "placeholderImg")
            self.indicator.stopAnimating()
            return
        }
        
        if let data = try? Data(contentsOf: url) {
            artImage.image = UIImage(data: data)
        }
        self.indicator.stopAnimating()
    }

}
