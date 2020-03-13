//
//  Date+Extensions.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/13/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

extension Date {
    public func dateString(_ format: String = "EEEE, MMM d, h:mm a") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
