//
//  ArtViewController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 30/4/2022.
//

import UIKit

class ArtViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var mainImgURL: URL?
    var additionaImgURL = [URL]()
    var storedImages = [UIImage]()
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        renderImages()
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = storedImages.count
        
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func renderImages() {
        print("Fetching images")
        guard let mainImg = mainImgURL else {
            storedImages.append(UIImage(named: "placeholderImg")!)
            return
        }
        
        if let data = try? Data(contentsOf: mainImg) {
            storedImages.append(UIImage(data: data)!)
        }
        
        for image in additionaImgURL {
            if let data = try? Data(contentsOf: image) {
                storedImages.append(UIImage(data: data)!)
            }
        }
        
        print("Completed")
    }

}

extension ArtViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storedImages.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "artImageCell", for: indexPath) as! ArtImageCollectionViewCell
        
        cell.artImage.image = storedImages[indexPath.row]
        cell.artImage.enableZoom()
        
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
