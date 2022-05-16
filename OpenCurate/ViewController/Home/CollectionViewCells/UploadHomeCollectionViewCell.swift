//
//  UploadHomeCollectionViewCell.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 16/5/2022.
//

import UIKit

class UploadHomeCollectionViewCell: UICollectionViewCell {

    // Convert class name to string
    static let identifier = String(describing: UploadHomeCollectionViewCell.self)
    
    @IBOutlet weak var uploadImageView: UIImageView!
    
    func setup(_ uploads: UploadImage) {
        if let data = uploads.image {
            uploadImageView.image = UIImage(data: data)
            return
        }
        
        uploadImageView.image = UIImage(named: "placeholderUpload")
    }

}
