//
//  CardTableViewCell.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    @IBOutlet weak var cardImageView: UIImageView!
    
    func updateCell(withCardImage cardImage: UIImage) {
        cardImageView.image = cardImage
    }
}
