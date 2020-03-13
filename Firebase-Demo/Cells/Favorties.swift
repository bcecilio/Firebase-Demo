//
//  Favorties.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/13/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import Firebase

struct Favorties {
    let itemName: String
    let favoriteDate: Timestamp
    let imageURL: String
    let itemId: String
    let price: Double
    let sellerId: String
    let sellerName: String
}

extension Favorties {
    init?(_ dictionary: [String: Any]) {
        guard let itemName = dictionary["itemName"] as? String,
            let favoriteDate = dictionary["favoritedDate"] as? Timestamp,
            let imageURL = dictionary["imageURL"] as? String,
            let itemId = dictionary["itemId"] as? String,
            let price = dictionary["price"] as? Double,
            let sellerName = dictionary["sellerName"] as? String,
            let sellerId = dictionary["sellerId"] as? String else {
                return nil
        }
        self.itemName = itemName
        self.favoriteDate = favoriteDate
        self.imageURL = imageURL
        self.itemId = itemId
        self.price = price
        self.sellerName = sellerName
        self.sellerId = sellerId
    }
}
