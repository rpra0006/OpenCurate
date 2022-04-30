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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            await requestArtFromObj()
        }
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
            
            navigationItem.title = artDataRequest.title
            
        }
        catch let error {
            print(error)
        }
    }


}
