//
//  HomeViewController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 22/4/2022.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var logoButton: UIBarButtonItem!
    @IBOutlet weak var departmentCollectionView: UICollectionView!
    
    let DEPARTMENT_REQUEST = "https://collectionapi.metmuseum.org/public/collection/v1/departments"
    
    var newDepartments = [DepartmentData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        logoButton.image = UIImage(named: "OpenCurateLogo")?.withRenderingMode(.alwaysOriginal)
        
        departmentCollectionView.delegate = self
        departmentCollectionView.dataSource = self
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


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newDepartments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DepartmentCollectionViewCell.identifier, for: indexPath) as! DepartmentCollectionViewCell
        cell.setup(newDepartments[indexPath.row])
        return cell
    }
}

