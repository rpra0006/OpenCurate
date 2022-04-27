//
//  METDepartmentData.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 27/4/2022.
//

import Foundation

class METDepartmentData: NSObject, Decodable {
    
    var departments: [DepartmentData]?
    
    private enum CodingKeys: String, CodingKey {
        case departments
    }
    
}
