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
    
    weak var delegate: EXTCardTableViewCellDelegate?
    
    @IBAction func cardPhotoImageViewTapped(_ sender: Any) {
        guard let photo = cardPhotoImageView.image,
            let photoData = UIImagePNGRepresentation(photo) else { return }
        delegate?.extCardPhotoWasTapped(photoData: photoData)
    }
    
    func updateCell(with photo: UIImage) {
        cardPhotoImageView.image = photo
    }
}

protocol EXTCardTableViewCellDelegate: class {
    func extCardPhotoWasTapped(photoData: Data)
}
