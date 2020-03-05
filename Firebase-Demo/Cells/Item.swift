//
//  Item.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

struct Item {
    let itemName: String
    let price: Double
    let itemId: String
    let listedDate: Date
    let sellerName: String
    let sellerId: String
    let categoryName: String
    let imageURL: String
}

extension Item {
    init(_ dictionary: [String: Any]) {
        self.itemName = dictionary["itemName"] as? String ?? "no itemName"
        self.price = dictionary["price"] as? Double ?? 0.0
        self.itemId = dictionary["itemId"] as? String ?? "no itemId"
        self.listedDate = dictionary["listedDate"] as? Date ?? Date()
        self.sellerName = dictionary["sellerName"] as? String ?? "no sellerName"
        self.sellerId = dictionary["sellerId"] as? String ?? "no sellerId"
        self.categoryName = dictionary["categoryName"] as? String ?? "no categoryName"
        self.imageURL = dictionary["imageURL"] as? String ?? "no imageURL"
    }
}
