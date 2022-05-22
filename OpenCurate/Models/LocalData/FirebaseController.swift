//
//  FirebaseController.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 5/5/2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth
import UIKit

class FirebaseController: NSObject, DatabaseProtocol {
    
    
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var uploadList: [UploadImage]
    var userUpload: [UserUpload]
    
    var authController: Auth
    var database: Firestore
    var storage: Storage // Firebase storage
    var artistRef: CollectionReference?
    var storageRef: StorageReference?
    var currentUser: FirebaseAuth.User?
    var authStatus: Bool
    
    override init() {
        FirebaseApp.configure()
        
        authController = Auth.auth()
        database = Firestore.firestore()
        storage = Storage.storage()
        storageRef = storage.reference()
        uploadList = [UploadImage]()
        userUpload = [UserUpload]()
        artistRef = database.collection("artist")
        storageRef = storage.reference()
        authStatus = false
        
        super.init()

    }
    
    func cleanup() {
        
    }
    
    
    func setupArtistListener(){
        
        artistRef = database.collection("artist")
        
        artistRef?.addSnapshotListener() {
            (querySnapshot, error) in guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseUploadSnapshot(snapshot: querySnapshot)

        }
        
    }
    
    
    func parseUploadSnapshot(snapshot: QuerySnapshot){
        
        let group = DispatchGroup()
        /*
        https://stackoverflow.com/questions/35906568/wait-until-swift-for-loop-with-asynchronous-network-requests-finishes-executing
          DispatchGroup allows asynchronous callback when all requests finishes.
         */
        
        snapshot.documentChanges.forEach{ (change) in
            group.enter()
            var parsedUpload: UploadImage?
            
            do {
                parsedUpload = try change.document.data(as: UploadImage.self)
            } catch {
                print("Unable to decode upload.")
                return
            }
            
            guard let uploadImage = parsedUpload else {
                print("Document doesn't exist")
                return
            }
            
            let imgLink = uploadImage.storageLink
            let imgRef = self.storageRef!.child("images/\(imgLink!)")
            imgRef.getData(maxSize: 1024 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error fetching: \(error)")
                }
                uploadImage.image = data
                group.leave()
            }
            
            if change.type == .added {
                
                uploadList.insert(uploadImage, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                
                uploadList[Int(change.oldIndex)] = uploadImage
            }
            else if change.type == .removed {
                uploadList.remove(at: Int(change.oldIndex))
            }
            
        }
        
        group.notify(queue: .main){
            
            self.listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.upload || listener.listenerType == ListenerType.all {
                    
                    listener.onUploadChange(change: .update, uploads: self.uploadList)
                }
            }
        }
        
    }
    
    func fetchUserUploads(_ completion: @escaping ([UserUpload]) -> Void) {
        
        self.userUpload.removeAll()
        let group = DispatchGroup()
        
        artistRef?.whereField("artistUID", isEqualTo: currentUser!.uid).getDocuments{
            (snapshot, error) in
            if let err = error {
                print("Error fetching documents: \(err)")
            }
            
            guard let snapshot = snapshot else {
                return
            }
            
            for document in snapshot.documents {
                group.enter()
                let storageURL = document.data()["storageLink"]
                let imgRef = self.storageRef!.child("images/\(storageURL!)")
                imgRef.getData(maxSize: 1024 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Error fetching: \(error)")
                    }
                    let upload = UserUpload()
                    upload.storageLink = storageURL as? Int
                    upload.image = UIImage(data: data!)
                    upload.id = document.documentID
                    self.userUpload.append(upload)
                    print("Found image: \(String(describing: data))")
                    group.leave()
                }
            }
            
            group.notify(queue: .main){
                completion(self.userUpload)
            }
        }
        
    }
    
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .upload || listener.listenerType == ListenerType.all {
            listener.onUploadChange(change:. update, uploads: uploadList)
        }
        
        if listener.listenerType == ListenerType.user || listener.listenerType == ListenerType.all {
            
            listener.onUserUploadChange(change: .update, userUpload: userUpload)
        }
        
        if listener.listenerType == .auth {
            listener.authSuccess(change: .update, status: authStatus)
        }
    }
    
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addArtwork(uploadData: Data, uploadImage: UploadImage) {
        
        let uploadUser = UserUpload()
        let timestamp = UInt(Date().timeIntervalSince1970) // Get current timestamp
        let imageRef = storageRef?.child("images/\(timestamp)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        // Upload to Firebase Storage
        let uploadTask = imageRef?.putData(uploadData, metadata: metadata)
        
        // Setup UploadImage object
        uploadImage.storageLink = Int(timestamp)
        uploadImage.artistUID = currentUser?.uid
        
        // Setup UserUpload object
        uploadUser.storageLink = uploadImage.storageLink
        uploadUser.image = UIImage(data: uploadData)
        
        uploadTask?.observe(.success) {
            // ADD IMAGES TO FIRESTORE DATABASE
            snapshot in
                do {
                    if let artistRef = try self.artistRef?.addDocument(from: uploadImage) {
                        uploadImage.id = artistRef.documentID
                        uploadUser.id = artistRef.documentID
                        print("Image uploaded to Firestore collection")
                        self.userUpload.append(uploadUser)
                       
                        self.listeners.invoke { (listener) in
                            if listener.listenerType == ListenerType.user || listener.listenerType == ListenerType.all {
                                
                                listener.onUserUploadChange(change: .update, userUpload: self.userUpload)
                            }
                        }
                    }
                } catch {
                    print("Failed to serialize image")
                }
        }
        
        uploadTask?.observe(.failure) {
            snapshot in
                print("\(String(describing: snapshot.error))")
        }
    }
    
    func deleteArtwork(row: Int) {
        
        // Delete from Firestore Database
        if let docId = userUpload[row].id {
            artistRef?.document(docId).delete()
        }
        
        // Delete from Firebase Storage
        if let filePath = userUpload[row].storageLink {
            let imageRef = storageRef?.child("images/\(filePath)")
            imageRef?.delete() { error in
                if let error = error {
                    print(error)
                } else {
                    print("Image deleted")
                    // File successfully deleted
                }
            }
        }
        
        
        self.userUpload.remove(at: row)
        
        // Invoke listeners
        self.listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.user || listener.listenerType == ListenerType.all {
                
                listener.onUserUploadChange(change: .update, userUpload: self.userUpload)
            }
        }
    }
    
    
    func signIn(email: String, password: String, callback: @escaping (Result<Any, Error>) -> Void) {
        
        Task {
            
            do {
                let authDataResult = try await authController.signIn(withEmail: email, password: password)
                currentUser = authDataResult.user
                authStatus = true
                invokeAuthListener()
                callback(.success("Success"))
            }
            catch {
                print("Firebase Authentication Failed with Error \(String(describing: error))")
                callback(.failure(error))
            }
            
        }
    }
    
    
    func register(email: String, password: String, callback: @escaping (Result<Any, Error>) -> Void) {
        
        Task {
            
            do {
                let authDataResult = try await authController.createUser(withEmail: email, password: password)
                currentUser = authDataResult.user
                authStatus = true
                invokeAuthListener()
                callback(.success("Success"))
            }
            catch {
                print("Firebase Authentication Failed with Error \(String(describing: error))")
                callback(.failure(error))
            }
        }

    }
    
    
    func invokeAuthListener() {
        
        self.setupArtistListener()
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.auth {
                
                listener.authSuccess(change: .update, status: authStatus)
            }
        }
    }
    
    func signOut(callback: @escaping (Result<Any, Error>) -> Void) {
        
        Task {
            do {
                try authController.signOut()
                currentUser = nil
                callback(.success("Success"))
            } catch {
                print("Log out error: \(error.localizedDescription)")
                callback(.failure(error))
            }
        }
    }
    
}
