//
//  DepartmentData.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 27/4/2022.
//

import Foundation

class DepartmentData: NSObject, Decodable {
    
    var departmentName: String?
    var departmentId: Int?
    
    private enum RootKeys: String, CodingKey {
        case departmentName = "displayName"
        case departmentId
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        departmentName = try container.decode(String.self, forKey: .departmentName)
        departmentId = try container.decode(Int.self, forKey: .departmentId)
    }
    
}
