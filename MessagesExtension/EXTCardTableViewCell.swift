//
//  EXTCardTableViewCell.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class EXTCardTableViewCell: UITableViewCell {

    @IBOutlet weak var cardPhotoImageView: UIImageView!
    
    func updateCell(with photo: UIImage) {
        cardPhotoImageView.image = photo
    }
}
