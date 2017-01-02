//
//  AllergenCell.swift
//  AllergyScannerTabbed
//
//  Created by nikash khanna on 10/6/15.
//  Copyright © 2015 nikash khanna. All rights reserved.
//

import UIKit

class AllergenCell: UITableViewCell {
    
    
    @IBOutlet var allergenLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        allergenLabel.layer.masksToBounds = true;
        allergenLabel.layer.cornerRadius = 8.0;
    }
    
    
}
