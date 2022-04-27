//
//  DepartmentCollectionViewCell.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 27/4/2022.
//

import UIKit

class DepartmentCollectionViewCell: UICollectionViewCell {
    
    // Convert class name to string
    static let identifier = String(describing: DepartmentCollectionViewCell.self)

    @IBOutlet weak var departmentLabel: UILabel!
 
    func setup(_ department: DepartmentData) {
        departmentLabel.text = department.departmentName
    }
}
