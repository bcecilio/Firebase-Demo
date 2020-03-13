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
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleTap(_:)))
        return gesture
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sellerNameLabel.textColor = .systemOrange
        sellerNameLabel.isUserInteractionEnabled = true
        sellerNameLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        print("was selected")
    }
    
    public func configureCell(for item: Item) {
        updateUI(imageURL: item.imageURL, itemName: item.itemName, sellerName: item.sellerName, date: item.listedDate, price: item.price)
    }
    
    public func configureCell(for favorite: Favorties) {
        updateUI(imageURL: favorite.imageURL, itemName: favorite.itemName, sellerName: favorite.sellerName, date: favorite.favoriteDate.dateValue(), price: favorite.price)
    }
    
    private func updateUI(imageURL: String, itemName: String, sellerName: String, date: Date, price: Double) {
        itemImageView.kf.setImage(with: URL(string: imageURL))
        itemLabel.text = itemName
        sellerNameLabel.text = "@\(sellerName)"
        dateLabel.text = date.description
        let price = String(format: "%.2f",price)
        priceLabel.text = "$\(price)"
    }
}
