//
//  UploadViewController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 11/5/2022.
//

import UIKit
import simd

class AccountViewController: UIViewController, DatabaseListener {
    
    
    var listenerType: ListenerType = ListenerType.user
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var userUploadCollectionView: UICollectionView!
    var userImages : [UIImage] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        userUploadCollectionView.delegate = self
        userUploadCollectionView.dataSource = self
        
        loadCollectionView()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    @IBAction func logoutButton(_ sender: Any) {
        
        databaseController?.signOut(){
            [weak self] result in
                switch result {
                    case .success(let p):
                    DispatchQueue.main.async {
                        self!.performSegue(withIdentifier: "logoutSegue", sender: sender)
                        print("Sign out successful")
                    }
                    case .failure(let error):
                    DispatchQueue.main.async {
                        self!.displayMessage(title: "Error", message: "Unable to signout.")
                    }
                }
        }
    }
    
    
    func loadCollectionView() {
        databaseController?.fetchUserUploads{ result in
            self.userImages = result
            self.userUploadCollectionView.reloadData()
            print(self.userImages.count)
        }
    }
    
    func onUserUploadChange(change: DatabaseChange, userUpload: [UIImage]) {
        userImages = userUpload
        userUploadCollectionView.reloadData()
    }
    
    
    func onUploadChange(change: DatabaseChange, uploads: [UploadImage]) {
        
    }
    
    func authSuccess(change: DatabaseChange, status: Bool) {
        
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


extension AccountViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "uploadImageCell", for: indexPath) as! UploadImageCollectionViewCell
        
        cell.uploadedImage.image = userImages[indexPath.row]
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Create UIAlertController
        let alertMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
        
        // Create Action Handlers
        
        let delete = UIAlertAction(title: "Delete", style: .default) { (action) -> Void in
            print("Item deleted at row \(indexPath.row)")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button")
        }
        
        alertMessage.addAction(delete)
        alertMessage.addAction(cancel)
        
        // Present alert message
        self.present(alertMessage, animated: true, completion: nil)
    }
}
