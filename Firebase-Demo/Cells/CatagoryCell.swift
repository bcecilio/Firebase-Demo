//
//  CatagoryCell.swift
//  Firebase-Demo
//
//  Created by Brendon Cecilio on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class CatagoryCell: UICollectionViewCell {
    
    @IBOutlet weak var catagoryImageView: UIImageView!
    @IBOutlet weak var catagoryNameLabel: UILabel!
    
    public func configureCell(for category: Category) {
        let colorImage = category.image.withTintColor(UIColor.generateRandomColor(), renderingMode: .alwaysOriginal)
        catagoryNameLabel.text = category.name
        catagoryImageView.image = colorImage
    }
    
}

extension UIColor {
  static func generateRandomColor() -> UIColor {
      let redValue = CGFloat.random(in: 0...1)
      let greenValue = CGFloat.random(in: 0...1)
      let blueValue = CGFloat.random(in: 0...1)
      let randomColor = UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
      return randomColor
  }
}
