//
//  StorageService.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageService {
    
    private let storageRef = Storage.storage().reference()
    
    public func uploadPhoto(userId: String? = nil, itemId: String? = nil, image: UIImage, completion: @escaping (Result<URL, Error>) -> ()) {
        // 1. convert a UIImage to data because this is the object we are posting to firebase storage
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        // we need to establish which bucket or collection or folder we will be saving the photo to
        var photoReference: StorageReference!
        if let userId = userId { // coming from profileViewController
            photoReference = storageRef.child("UserProfilePhotos/\(userId).jpg")
        } else if let itemId = itemId { // coming from createItemViewController
            photoReference = storageRef.child("ItemsPhotos/\(itemId).jpg")
        }
        // configure metadata for the object being uploaded
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg" // MIME type
        
        let _ = photoReference.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else if let _ = metadata {
                photoReference.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                    }
                }
            }
        }
    }
}
