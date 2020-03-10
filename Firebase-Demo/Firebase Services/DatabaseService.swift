//
//  DatabaseService.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class DatabaseService {
    
    static let itemsCollection = "items"
    static let usersCollection = "users"
    static let commentsCollection = "comments" // sub collection on an item document
    
    // collection -> document -> collection -> document -> ....
    
    // reference to the firebase fire store database
    private let database = Firestore.firestore()
    
    public func createItem(itemName: String, price: Double, category: Category, displayName: String, completion: @escaping (Result<String, Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser else {return}
        
        // generate a document id
        let document = database.collection(DatabaseService.itemsCollection).document()
        
        // create a document un our "items" collection
        database.collection(DatabaseService.itemsCollection).document(document.documentID).setData(["itemName":itemName, "price":price, "itemId": document.documentID, "listedDate":Timestamp(date: Date()),"sellerName": displayName,"sellerID": user.uid, "categoryName": category.name]) { (error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(document.documentID))
            }
        }
    }
    
    public func createDatabaseUser(authDataResult: AuthDataResult, completion: @escaping(Result<Bool, Error>) -> ()) {
        
        guard let email = authDataResult.user.email else {
            return
        }
        
        database.collection(DatabaseService.usersCollection).document(authDataResult.user.uid).setData(["email" : email, "createdDate": Timestamp(date: Date()), "userId": authDataResult.user.uid]) { (error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func updateDatabaseUser(displayName: String, imageUrl: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else {return}
        database.collection(DatabaseService.usersCollection).document(user.uid).updateData(["imageUrl" : imageUrl, "displayName": displayName]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func deleteItem(item: Item, completion: @escaping (Result<Bool,Error>) -> ()) {
        database.collection(DatabaseService.itemsCollection).document(item.itemId).delete { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
}
