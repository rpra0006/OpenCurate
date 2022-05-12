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

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var uploadList: [UploadImage]
    
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
        uploadList = [UploadImage]()
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

        
            //self.setupTeamListener()

        }
    }
    
    
    func setupStorageListener(){
        // To be added
        storageRef = storage.reference()
        
    }
    
    
    func parseUploadSnapshot(snapshot: QuerySnapshot){
        
        
        snapshot.documentChanges.forEach{ (change) in
            
            var parsedUpload: UploadImage?
            
            do {
                parsedUpload = try change.document.data(as: UploadImage.self)
            } catch {
                print("Unable to decode hero. Is the hero malformed?")
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
    
    
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .upload || listener.listenerType == ListenerType.all {
            listener.onUploadChange(change:. update, uploads: uploadList)
        }
        
        if listener.listenerType == .auth {
            listener.authSuccess(change: .update, status: authStatus)
        }
    }
    
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addArtwork(uploadData: Data, uploadImage: UploadImage) {
        
        //storageRef = storage.reference() // Need to set this up in setupStorageListener()
        
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
                    }
                } catch {
                    print("Failed to serialize hero")
                }
        }
        
        uploadTask?.observe(.failure) {
            snapshot in
                print("\(String(describing: snapshot.error))")
        }
    }
    
    func deleteArtwork() {
        
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
