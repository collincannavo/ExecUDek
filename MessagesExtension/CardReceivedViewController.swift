//
//  CardReceivedViewController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/31/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import SharedExecUDek
import Messages

class CardReceivedViewController: UIViewController {
    
    var card: Card?
    var cardView: CommonCardTableViewCell?
    var delegate: CardReceivedViewControllerDelegate?
    
    @IBOutlet weak var receivedCardPlaceholder: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCardView()
        setupCardView()
    }
    
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        guard let card = card else { return }
        MessageController.save(card)
        
        delegate?.userDidHandleReceivedCard()
    }
    
    @IBAction func rejectButtonTapped(_ sender: UIButton) {
        delegate?.userDidHandleReceivedCard()
    }
    
    func loadCardView() {
        let bundle = Bundle(identifier: "com.ganleyapps.SharedExecUDek")
        cardView = bundle?.loadNibNamed("CommonCardTableViewCell", owner: self, options: nil)?.first as? CommonCardTableViewCell
    }
    
    func setupCardView() {
        guard let cardView = cardView,
            let view = cardView.view else { return }
        
        cardView.hideShareButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        receivedCardPlaceholder.addSubview(view)
        
        view.leadingAnchor.constraint(equalTo: receivedCardPlaceholder.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: receivedCardPlaceholder.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: receivedCardPlaceholder.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: receivedCardPlaceholder.bottomAnchor).isActive = true
        
        cardView.nameLabel.text = card?.name
        cardView.titleLabel.text = card?.title
        cardView.emailLabel.text = card?.email
        cardView.card = card
        
        if let data = card?.logoData {
            let image = UIImage(data: data)
            cardView.photoButton.setBackgroundImage(image, for: .normal)
            cardView.photoButton.setTitle("", for: .normal)
        }
        
        cardView.layer.cornerRadius = 20.0
    }
}

protocol CardReceivedViewControllerDelegate: class {
    func userDidHandleReceivedCard()
}
