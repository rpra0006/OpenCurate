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
    //var localArtData = [ArtUpload]
    
    var authController: Auth
    var database: Firestore
    var heroesRef: CollectionReference?
    var teamsRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    var authStatus: Bool
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        authStatus = false
        
        super.init()

    }
    
    func cleanup() {
        
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        /*
        if listener.listenerType == .upload {
            listener.onUploadChange(change:. update, localArtData: localArtData)
        }
        */
        
        if listener.listenerType == .auth {
            listener.authSuccess(change: .update, status: authStatus)
        }
    }
    
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
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
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.auth {
                
                listener.authSuccess(change: .update, status: authStatus)
            }
        }
    }
    
    func signOut() {
        
        do {
            try authController.signOut()
            currentUser = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }
    
    
}
