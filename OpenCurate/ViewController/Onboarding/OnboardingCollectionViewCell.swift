//
//  OnboardingCollectionViewCell.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 22/4/2022.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    // Convert class name to string
    static let identifier = String(describing: OnboardingCollectionViewCell.self)
    
    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var slideTitleLabel: UILabel!
    @IBOutlet weak var slideDescriptionLabel: UILabel!
    
    func setup(_ slide: OnboardingSlide){
        
        slideImageView.image = slide.image
        slideTitleLabel.text = slide.title
        slideDescriptionLabel.text = slide.description
    }
}
