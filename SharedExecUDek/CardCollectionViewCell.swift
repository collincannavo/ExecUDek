//
//  CardCollectionViewCell.swift
//  ExecUDek
//
//  Created by Collin Cannavo on 8/3/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

public class CardCollectionViewCell: UICollectionViewCell {
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = 12
        
    }
    
    public var card: Card?
    
    @IBOutlet public weak var photoButton: UIButton!
    @IBOutlet public weak var nameLabel: UILabel!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var cellLabel: UILabel!
    @IBOutlet public weak var emailLabel: UILabel!
    @IBOutlet public weak var entireCardButton: UIButton!
    @IBOutlet public weak var shareButton: UIButton!
    @IBOutlet public weak var view: UIView!
    @IBOutlet weak var shareImage: UIImageView!
    
    @IBAction public func addCompanyLogoButtonTapped(_ sender: Any) {
        guard let buttonTapped = sender as? UIButton else { return }
        delegate?.photoSelectCellSelected?(cellButtonTapped: buttonTapped)
    }
    
    @IBAction public func entireCardButtonTapped(_ sender: UIButton) {
        guard let card = card else { return }
        delegate?.entireCardWasTapped?(card: card, cell: self)
    }
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        actionSheetDelegate?.actionSheetSelected(cellButtonTapped: sender, cell: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        return UICollectionViewCell()
    }
    
    public func updateCell(withCardImage: UIImage) {
        guard let name = nameLabel.text,
            let title = titleLabel.text,
            let cell = cellLabel.text,
            let email = emailLabel.text
            else { return }
        
        card?.name = name
        card?.email = email
        card?.cell = cell
        card?.title = title
        
        layer.cornerRadius = 20.0
        view.backgroundColor = UIColor.clear
        
        shareButton.superview?.bringSubview(toFront: view)
    }
    
    public func updateViews() {
        guard let card = card else { return }
        
        nameLabel.text = card.name
        titleLabel.text = card.title
        cellLabel.text = card.cell
        emailLabel.text = card.email
        
        if let data = card.logoData {
            let image = UIImage(data: data)
            
            photoButton.setBackgroundImage(image, for: .normal)
            photoButton.setBackgroundImage(image, for: .disabled)
            photoButton.setTitle("", for: .normal)
        }
    }
    
    public override func prepareForReuse() {
        entireCardButton.isEnabled = false
        shareButton.isHidden = false
        photoButton.isEnabled = true
        shareImage.isHidden = false
        
        photoButton.setBackgroundImage(nil, for: .normal)
        photoButton.setBackgroundImage(nil, for: .disabled)
        nameLabel.text = ""
        titleLabel.text = ""
        cellLabel.text = ""
        emailLabel.text = ""
    }
    
    public func enableEntireCardButton() {
        entireCardButton.isEnabled = true
    }
    
    public func hideShareButton() {
        shareButton.isHidden = true
    }
    
    public func hideShareImage() {
        shareImage.isHidden = true
    }
    
    public func disablePhotoButton() {
        photoButton.isEnabled = false
    }
    
    
    // MARK: - Delegate properties
    
    public weak var delegate: PhotoSelctorCellDelegate?
    public weak var actionSheetDelegate: ActionSheetDelegate?
}

// MARK: - Protocols

@objc public protocol PhotoSelctorCellDelegate : class, NSObjectProtocol {
    @objc optional func photoSelectCellSelected(cellButtonTapped: UIButton)
    @objc optional func entireCardWasTapped(card: Card, cell: CardCollectionViewCell)
}

public protocol ActionSheetDelegate : class {
    func actionSheetSelected(cellButtonTapped: UIButton, cell: CardCollectionViewCell)
}
