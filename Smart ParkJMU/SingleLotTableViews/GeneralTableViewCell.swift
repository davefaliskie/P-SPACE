//
//  GeneralTableViewCell.swift
//  Smart ParkJMU
//
//  Created by Riley Sung on 3/1/16.
//  Copyright © 2016 Riley Sung. All rights reserved.
//

import UIKit

class GeneralTableViewCell: UITableViewCell {
    
    
    // Class used for customizing cells in Single Lot View
    
    @IBOutlet weak var lotPropertyNameLabel: UILabel!
    @IBOutlet weak var lotPropertySpotInfoLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
