//
//  SwitchCell.swift
//  Yelp
//
//  Created by Nikrad Mahdi on 9/22/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
  optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {

  @IBOutlet weak var switchLabel: UILabel!
  @IBOutlet weak var onSwitch: UISwitch!

  weak var delegate: SwitchCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()
    onSwitch.addTarget(self, action: "switchValueChanged:", forControlEvents: UIControlEvents.ValueChanged)

  }

  func switchValueChanged(sender: AnyObject?) {
    delegate?.switchCell?(self, didChangeValue: onSwitch.on)
  }
}
