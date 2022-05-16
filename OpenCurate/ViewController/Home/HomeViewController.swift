//
//  HomeViewController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 22/4/2022.
//

import UIKit

class HomeViewController: UIViewController, DatabaseListener {
    
    var listenerType: ListenerType = .upload
    weak var databaseController: DatabaseProtocol?
    
    var uploadHomeList = [UploadImage]()
    
    @IBOutlet weak var logoButton: UIBarButtonItem!
    @IBOutlet weak var departmentCollectionView: UICollectionView!
    @IBOutlet weak var uploadCollectionView: UICollectionView!
    
    let DEPARTMENT_REQUEST = "https://collectionapi.metmuseum.org/public/collection/v1/departments"
    
    var newDepartments = [DepartmentData]()
    var selectedDepartment: DepartmentData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        logoButton.image = UIImage(named: "OpenCurateLogo")?.withRenderingMode(.alwaysOriginal)
        
        departmentCollectionView.delegate = self
        departmentCollectionView.dataSource = self
        uploadCollectionView.delegate = self
        uploadCollectionView.dataSource = self
        registerCells()
        
        Task {
            await loadDepartmentViewCell()
            departmentCollectionView.reloadData()
        }
        
        
        //navigationController?.navigationBar.barTintColor = UIColor.white
        // Do any additional setup after loading the view.
    }

    func loadDepartmentViewCell() async {
        
        guard let requestURL = URL(string: DEPARTMENT_REQUEST) else {
            print("Invalid URL")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            
            let decoder = JSONDecoder()
            let METDepartmentData = try decoder.decode(METDepartmentData.self, from: data)
            
            if let department = METDepartmentData.departments{
                newDepartments.append(contentsOf: department)
            }
            
        }
        catch let error {
            print(error)
        }
    }
    
    private func registerCells(){
        departmentCollectionView.register(UINib(nibName: DepartmentCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: DepartmentCollectionViewCell.identifier)
        uploadCollectionView.register(UINib(nibName: UploadHomeCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: UploadHomeCollectionViewCell.identifier)
    }
    
    func onUploadChange(change: DatabaseChange, uploads: [UploadImage]) {
        
        uploadHomeList = Array(uploads.prefix(5)) // Get array slice of first 5 object
        
        // Create an Image for "View More" and append to end of uploadHomeList
        
        uploadCollectionView.reloadData()
        
    }
    
    func onUserUploadChange(change: DatabaseChange, userUpload: [UIImage]) {
        
    }
    
    func authSuccess(change: DatabaseChange, status: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "departmentTableSegue" {
            let destination = segue.destination as! DepartmentTableViewController
            destination.navigationItem.title = selectedDepartment?.departmentName
            destination.departmentId = selectedDepartment?.departmentId
        }
    }


}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
            case departmentCollectionView:
                return newDepartments.count
            case uploadCollectionView:
                return uploadHomeList.count
            default:
                return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
            case departmentCollectionView:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DepartmentCollectionViewCell.identifier, for: indexPath) as! DepartmentCollectionViewCell
                cell.setup(newDepartments[indexPath.row])
                return cell
            case uploadCollectionView:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UploadHomeCollectionViewCell.identifier, for: indexPath) as! UploadHomeCollectionViewCell
                cell.setup(uploadHomeList[indexPath.row])
                return cell
            default:
                return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDepartment = newDepartments[indexPath.row]
        performSegue(withIdentifier: "departmentTableSegue", sender: nil)
    }
}

