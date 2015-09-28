//
//  BusinessCell.swift
//  Yelp
//
//  Created by Nikrad Mahdi on 9/21/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

  @IBOutlet weak var thumbImageView: UIImageView!
  @IBOutlet weak var ratingImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var reviewsCountLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var categoriesLabel: UILabel!

  var business: Business! {
    didSet {
      nameLabel.text = business.name
      thumbImageView.setImageWithURL(business.imageURL)
      categoriesLabel.text = business.categories
      addressLabel.text = business.address
      reviewsCountLabel.text = "\(business.reviewCount!) reviews"
      ratingImageView.setImageWithURL(business.ratingImageURL)
      distanceLabel.text = business.distance
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    thumbImageView.layer.cornerRadius = 3
    thumbImageView.clipsToBounds = true
  }

  override func layoutSubviews() {
    super.layoutSubviews()
  }
}
