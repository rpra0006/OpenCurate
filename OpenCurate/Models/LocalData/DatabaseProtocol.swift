//
//  DatabaseProtocol.swift
//  OpenCurate
//
//  Created by Richard Pranjatno on 5/5/2022.
//

import Foundation

enum DatabaseChange{
    case add
    case remove
    case update
}

enum ListenerType {
    case auth
    case upload
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    //func onUploadChange(change: DatabaseChange, localArtData: [ArtUpload])
    func authSuccess(change: DatabaseChange, status: Bool)
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    //func addArtwork(name: String, abilities:String, universe: Universe) -> Superhero
    //func deleteArtwork(hero: Superhero)

    func signIn(email: String, password: String, callback: @escaping (Result<Any, Error>) -> Void)
    func register(email: String, password: String, callback: @escaping (Result<Any, Error>) -> Void)
    func signOut()
}

