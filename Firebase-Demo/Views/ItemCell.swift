//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Kingfisher

protocol ItemCellDelegate: AnyObject {
    func didSelectSellerName(_ itemCell: ItemCell, item: Item)
}

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    private var currentItem: Item!
    weak var delegate: ItemCellDelegate?
    
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
        print("\(currentItem.itemName) selected")
        delegate?.didSelectSellerName(self, item: currentItem)
    }
    
    public func configureCell(for item: Item) {
        currentItem = item
        updateUI(imageURL: item.imageURL, itemName: item.itemName, sellerName: item.sellerName, date: item.listedDate.dateValue(), price: item.price)
    }
    
    public func configureCell(for favorite: Favorties) {
        updateUI(imageURL: favorite.imageURL, itemName: favorite.itemName, sellerName: favorite.sellerName, date: favorite.favoriteDate.dateValue(), price: favorite.price)
    }
    
    private func updateUI(imageURL: String, itemName: String, sellerName: String, date: Date, price: Double) {
        itemImageView.kf.setImage(with: URL(string: imageURL))
        itemLabel.text = itemName
        sellerNameLabel.text = "@\(sellerName)"
        dateLabel.text = date.dateString()
        let price = String(format: "%.2f",price)
        priceLabel.text = "$\(price)"
    }
}
