//
//  UserUpload.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 21/5/2022.
//

import Foundation
import FirebaseFirestoreSwift
import UIKit

class UserUpload: NSObject {
    
    @DocumentID var id:String?
    var storageLink: Int?
    var image: UIImage?
    
}
