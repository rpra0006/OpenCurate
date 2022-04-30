//
//  DepartmentObjectData.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 30/4/2022.
//

import Foundation

class DepartmentObjectData: NSObject, Decodable {
    
    var objectIDs: [Int]?
    
    private enum CodingKeys: String, CodingKey {
        case objectIDs
    }
    
}
