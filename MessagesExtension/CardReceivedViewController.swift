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
    var cardView: CardCollectionViewCell?
    var delegate: CardReceivedViewControllerDelegate?
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var indicatorView: UIView!
    
    @IBOutlet weak var receivedCardPlaceholder: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCardView()
        setupCardView()
        
        indicatorView = ActivityIndicator.indicatorView(with: activityIndicator)
    }
    
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        activityIndicator.startAnimating()
        ActivityIndicator.addAndAnimateIndicator(indicatorView, to: view)
        
        guard let card = card else { return }
        MessageController.save(card) { (success) in
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                ActivityIndicator.animateAndRemoveIndicator(self.indicatorView, from: self.view)
                
                if success {
                    self.delegate?.userDidHandleReceivedCard()
                } else {
                    self.presentUnableToSaveAlert {
                        self.delegate?.userDidHandleReceivedCard()
                    }
                }
            }
        }
    }
    
    @IBAction func rejectButtonTapped(_ sender: UIButton) {
        delegate?.userDidHandleReceivedCard()
    }
    
    func loadCardView() {
        let bundle = Bundle(identifier: "com.ganleyApps.SharedExecUDek")
        cardView = bundle?.loadNibNamed("CardCollectionViewCell", owner: self, options: nil)?.first as? CardCollectionViewCell
    }
    
    func setupCardView() {
        guard let cardView = cardView,
            let view = cardView.view else { return }
        
        cardView.hideShareButton()
        cardView.hideShareImage()
        view.translatesAutoresizingMaskIntoConstraints = false
        receivedCardPlaceholder.addSubview(view)
        
        view.leadingAnchor.constraint(equalTo: receivedCardPlaceholder.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: receivedCardPlaceholder.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: receivedCardPlaceholder.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: receivedCardPlaceholder.bottomAnchor).isActive = true
        
        cardView.nameLabel.text = card?.name
        cardView.titleLabel.text = card?.title
        cardView.emailLabel.text = card?.email
        cardView.cellLabel.text = card?.cell
        cardView.card = card
        cardView.hideEditButton()
        
        if let data = card?.logoData {
            let image = UIImage(data: data)
            cardView.photoButton.setBackgroundImage(image, for: .normal)
        }
        cardView.photoButton.setTitle("", for: .normal)
        
        cardView.layer.cornerRadius = 20.0
    }
    
    func presentUnableToSaveAlert(with completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Unable to Save Card", message: "This card already exists in your wallet", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (_) in
            completion()
        }
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

protocol CardReceivedViewControllerDelegate: class {
    func userDidHandleReceivedCard()
}
