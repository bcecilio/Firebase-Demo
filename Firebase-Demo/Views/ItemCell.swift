//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Kingfisher

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var sellerName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    public func configureCell(for item: Item) {
        itemImageView.kf.setImage(with: URL(fileURLWithPath: item.imageURL))
        itemLabel.text = item.itemName
        sellerName.text = "@\(item.sellerName)"
        dateLabel.text = item.listedDate.description
        let price = String(format: "%.2f", item.price)
        priceLabel.text = "$\(price)"
    }
}
