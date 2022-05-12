//
//  UploadImage.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 12/5/2022.
//

import Foundation
import FirebaseFirestoreSwift


class UploadImage: NSObject, Codable {
    
    @DocumentID var id:String?
    var artistName: String?
    var imageTitle: String?
    var storageLink: Int?
    var artistUID: String?
    
}
