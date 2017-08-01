//
//  CommonCardTableViewCell.swift
//  ExecUDek
//
//  Created by Collin Cannavo on 7/27/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

public class CommonCardTableViewCell: UITableViewCell {
    
    public var card: Card?
    
    @IBOutlet public weak var photoButton: UIButton!
    @IBOutlet public weak var nameLabel: UILabel!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var cellLabel: UILabel!
    @IBOutlet public weak var emailLabel: UILabel!
    @IBOutlet public weak var entireCardButton: UIButton!
    @IBOutlet public weak var shareButton: UIButton!
    @IBOutlet weak var view: UIView!
    
    @IBAction public func addCompanyLogoButtonTapped(_ sender: Any) {
        guard let buttonTapped = sender as? UIButton else { return }
        delegate?.photoSelectCellSelected?(cellButtonTapped: buttonTapped)
    }
    
    @IBAction public func entireCardButtonTapped(_ sender: UIButton) {
        guard let card = card else { return }
        delegate?.entireCardWasTapped?(card: card, cell: self)
    }
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        actionSheetDelegate?.actionSheetSelected(cellButtonTapped: sender)
        print("Button tapped")
    }
    
    public func updateCell(withCardImage: UIImage) {
        guard let name = nameLabel.text,
            let title = titleLabel.text,
            let cell = cellLabel.text,
            let email = emailLabel.text
            else { return }
        
        let numberFormatter = NumberFormatter()
        let cellphone = numberFormatter.number(from: cell)
        
        card?.name = name
        card?.email = email
        card?.cell = cellphone as? Int
        card?.title = title
        
        layer.cornerRadius = 20.0
        
//         view.bringSubview(toFront: shareButton)
//        view.insertSubview(photoButton, aboveSubview: shareButton)
        shareButton.superview?.bringSubview(toFront: view)
    }
    
    public func updateViews() {
        
    }
    
    public override func prepareForReuse() {
        entireCardButton.isEnabled = false
    }
    
    public func enableEntireCardButton() {
        entireCardButton.isEnabled = true
    }
    
    // MARK: - Delegate properties
    
    public weak var delegate: PhotoSelctorCellDelegate?
    public weak var actionSheetDelegate: ActionSheetDelegate?
}

    // MARK: - Protocols

@objc public protocol PhotoSelctorCellDelegate : class, NSObjectProtocol {
    @objc optional func photoSelectCellSelected(cellButtonTapped: UIButton)
    @objc optional func entireCardWasTapped(card: Card, cell: CommonCardTableViewCell)
}

public protocol ActionSheetDelegate : class {
    func actionSheetSelected(cellButtonTapped: UIButton)
}
