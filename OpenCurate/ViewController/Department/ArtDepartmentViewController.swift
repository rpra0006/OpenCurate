//
//  ArtDepartmentViewController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 30/4/2022.
//

import UIKit

class ArtDepartmentViewController: UIViewController {
    
    let REQUEST_ART_STRING = "https://collectionapi.metmuseum.org/public/collection/v1/objects/"
    var objectId: String?
    var imageURL: URL?
    
    
    @IBOutlet weak var artTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var artistBioLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var artCultureLabel: UILabel!
    @IBOutlet weak var artTypeLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        artTitleLabel.numberOfLines = 0 // Remove Truncation at the end
        Task {
            await requestArtFromObj()
        }
        
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "viewArtSegue" {
            if let destination = segue.destination as? ArtViewController {
                destination.imgURL = imageURL
                destination.hidesBottomBarWhenPushed = true
            }

        }
    }

    
    
    // Request Art Details from Object
    func requestArtFromObj() async{
            
        guard let requestURL = URL(string: REQUEST_ART_STRING + objectId!) else {
            print("Invalid URL")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            
            let decoder = JSONDecoder()
            
            let artDataRequest = try decoder.decode(METArtData.self, from: data)
            
            if artDataRequest.title!.isEmpty {
                artTitleLabel.text = "N/A"
            } else {
                artTitleLabel.text = artDataRequest.title
            }
            
            if artDataRequest.objectDate!.isEmpty {
                dateLabel.text = "N/A"
            } else {
                dateLabel.text = artDataRequest.objectDate
            }
            
            if artDataRequest.artistDisplayBio!.isEmpty {
                artistBioLabel.text = "N/A"
            } else {
                artistBioLabel.text = artDataRequest.artistDisplayBio
            }
            
            if artDataRequest.artistDisplayName!.isEmpty {
                artistNameLabel.text = "N/A"
            } else {
                artistNameLabel.text = artDataRequest.artistDisplayName
            }
            
            if artDataRequest.period!.isEmpty {
                periodLabel.text = "N/A"
            } else {
                periodLabel.text = artDataRequest.period
            }
            
            if artDataRequest.culture!.isEmpty {
                artCultureLabel.text = "N/A"
            } else {
                artCultureLabel.text = artDataRequest.culture
            }
            
            if artDataRequest.objectName!.isEmpty {
                artTypeLabel.text = "N/A"
            } else {
                artTypeLabel.text = artDataRequest.objectName
            }
        
            if let imageString = artDataRequest.primaryImage {
                imageURL = URL(string: imageString)
            }
            
            
        }
        catch let error {
            print(error)
        }
    }
    
    @IBAction func viewArtButton(_ sender: Any) {
        performSegue(withIdentifier: "viewArtSegue", sender: self)
    }
}
