//
//  METArtData.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 30/4/2022.
//

import Foundation

class METArtData: NSObject, Decodable {
    
    var objectID: Int?
    var primaryImage: String?
    var objectName: String?
    var title: String?
    var culture: String?
    var period: String?
    var artistDisplayName: String?
    var artistDisplayBio: String?
    var objectDate: String?
    var additionalImages: [String]?
    
    
    private enum CodingKeys: String, CodingKey {
        case objectID
        case primaryImage
        case objectName
        case title
        case culture
        case period
        case artistDisplayName
        case artistDisplayBio
        case objectDate
        case additionalImages
    }
    
}
