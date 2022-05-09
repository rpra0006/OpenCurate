//
//  OnboardingViewController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 22/4/2022.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var onboardingCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var slides: [OnboardingSlide] = []
    
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any addiitonal setup after loading the view
        
        onboardingCollectionView.delegate = self
        onboardingCollectionView.dataSource = self
        
        // Style Button
        continueButton.layer.borderColor = UIColor.systemOrange.cgColor
        
        
        slides = [
            OnboardingSlide(image: UIImage(named: "StarryNight")!, title: "Discover Artworks", description: "OpenCurate displays artworks from the Metropolitan Museum of Art Met Collection, with over 5000 years of art from around the world."),
            OnboardingSlide(image: UIImage(named: "CloudUpload")!, title: "Upload Your Own Artwork", description: "Registered users have the opportunity to showcase their own artwork in our dedicated section."),
            OnboardingSlide(image: UIImage(named: "GalleryMap")!, title: "Find Your Nearest Art Gallery", description: "If a virtual art gallery isn't enough to satisfy your curiosity, we will locate art galleries in your city.")
        ]
    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
        pageControl.currentPage = currentPage

    }
    
}
