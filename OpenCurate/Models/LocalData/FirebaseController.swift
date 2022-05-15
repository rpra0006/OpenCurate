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
    var userUpload: [UIImage]
    
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
        userUpload = [UIImage]()
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
        
        snapshot.documentChanges.forEach{ (change) in
            
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
            
            if change.type == .added {
                
                uploadList.insert(uploadImage, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                
                uploadList[Int(change.oldIndex)] = uploadImage
            }
            else if change.type == .removed {
                uploadList.remove(at: Int(change.oldIndex))
            }
            
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.upload || listener.listenerType == ListenerType.all {
                    
                    listener.onUploadChange(change: .update, uploads: uploadList)
                }
            }
            
        }
    }
    
    func fetchUserUploads(_ completion: @escaping ([UIImage]) -> Void) {
        
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
                    self.userUpload.append(UIImage(data: data!)!)
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
        
        let timestamp = UInt(Date().timeIntervalSince1970)
        let imageRef = storageRef?.child("images/\(timestamp)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        let uploadTask = imageRef?.putData(uploadData, metadata: metadata)
        
        // Setup UploadImage object
        uploadImage.storageLink = Int(timestamp)
        uploadImage.artistUID = currentUser?.uid
        
        uploadTask?.observe(.success) {
            // ADD IMAGES TO FIRESTORE DATABASE
            snapshot in
                do {
                    if let artistRef = try self.artistRef?.addDocument(from: uploadImage) {
                        uploadImage.id = artistRef.documentID
                        print("Image uploaded to Firestore collection")
                        self.userUpload.append(UIImage(data: uploadData)!)
                       
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
    
    func deleteArtwork() {
        
    }
    
    
    func saveImageData(filename: String, imageData:Data) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try imageData.write(to: fileURL)
        }
        catch {
            print("Error writing file: \(error.localizedDescription)")
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
        
        //self.setupArtistListener() To instantiate uploadlist once user has logged in
        
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
