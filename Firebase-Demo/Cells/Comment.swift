//
//  Comment.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import Firebase

struct Comment {
    let commentDate: Timestamp
    let commentNBy: String
    let itemId: String
    let itemName: String
    let sellerName: String
    let text: String
}

extension Comment {
    init(_ dictionary: [String: Any]) {
        self.commentDate = dictionary["commentDate"] as? Timestamp ?? Timestamp(date: Date())
        self.commentNBy = dictionary["commentBy"] as? String ?? "no commentedBy name"
        self.itemId = dictionary["itemId"] as? String ?? "no itemId"
        self.itemName = dictionary["itemName"] as? String ?? "no itemName"
        self.sellerName = dictionary["sellerName"] as? String ?? "no sellerName"
        self.text = dictionary["text"] as? String ?? "no text"
    }
}
