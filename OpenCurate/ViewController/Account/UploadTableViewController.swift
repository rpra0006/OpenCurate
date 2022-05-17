//
//  UploadTableTableViewController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 18/5/2022.
//

import UIKit

class UploadTableViewController: UITableViewController, DatabaseListener {
    
    var listenerType: ListenerType = .upload
    let CELL_UPLOAD = "uploadIdCell"
    var uploadList = [UploadImage]()
    var selectedUpload: UploadImage?
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return uploadList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_UPLOAD, for: indexPath)

        // Configure the cell...
        let uploadId = uploadList[indexPath.row]
        cell.textLabel?.text = String(uploadId.storageLink!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedUpload = uploadList[indexPath.row]
        
        performSegue(withIdentifier: "uploadSelectSegue", sender: self)
    }
    

    func onUploadChange(change: DatabaseChange, uploads: [UploadImage]) {
        uploadList = uploads
        tableView.reloadData()
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
        if segue.identifier == "uploadSelectSegue" {
            if let destination = segue.destination as? UploadSelectViewController {
                destination.uploadImage = selectedUpload
            }
        }
    }
    

}
