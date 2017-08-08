//
//  UserProfileCollectionViewController.swift
//  ExecUDek
//
//  Created by Collin Cannavo on 8/4/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import SharedExecUDek
import NotificationCenter
import MultipeerConnectivity
import MessageUI

class UserProfileCollectionViewController: UIViewController, ActionSheetDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, MultipeerControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let overlap: CGFloat = -120.0
    var card = CardCollectionViewCell()

    var selectedCard: Card?
    var customNavigationController: CustomNavigationController {
        return self.navigationController as? CustomNavigationController ?? CustomNavigationController()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func multipeerButtonTapped(_ sender: UIBarButtonItem) {
        customNavigationController.confirmChangeOfMultipeer()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell else { return }
        
        if let card = cell.card {
            selectedCard = card
            
            performSegue(withIdentifier: "editCardFromUser", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle(identifier: "com.ganleyApps.SharedExecUDek")
        let cardXIB = UINib(nibName: "CardCollectionViewCell", bundle: bundle)
        
        collectionView.register(cardXIB, forCellWithReuseIdentifier: "collectionCardCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
       let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        self.collectionView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
        MultipeerController.shared.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.frame.width
        
        return CGSize(width: collectionViewWidth, height: (collectionViewWidth * 0.518731988472622))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return overlap
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else { break }
        
        collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        
        case .changed:
            guard let view = gesture.view else { break }
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: view))
            
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PersonController.shared.currentPerson?.personalCards.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = PersonController.shared.currentPerson?.personalCards[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCardCell", for: indexPath) as? CardCollectionViewCell,
            let newCard = card else { return CardCollectionViewCell() }
        
        if let cellPhone = newCard.cell {
            cell.cellLabel.text = cellPhone
        }
        cell.actionSheetDelegate = self
        cell.nameLabel.text = newCard.name
        cell.titleLabel.text = newCard.title
        cell.cellLabel.text = newCard.cell
        cell.emailLabel.text = newCard.email
        cell.card = newCard
        if let data = card?.logoData {
            let image = UIImage(data: data)
            
            cell.photoButton.setBackgroundImage(image, for: .disabled)
            cell.photoButton.setTitle("", for: .disabled)
        }
        
        cell.disablePhotoButton()
        
        setupCardTableViewCellShadow(cell)
        setupCardTableViewCellBorderColor(cell)
        tableViewBackgroundColor()
        setupCardTableViewCell(cell)
        
        collectionView.bringSubview(toFront: cell)
        
        cell.actionSheetDelegate = self
        
        return cell
        
    }
    
    // MARK: - MF message view controller delegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCardFromUser" {
            if let destinationNavController = segue.destination as? UINavigationController,
                let destinationVC = destinationNavController.viewControllers.first as?
                CardTemplateTableViewController {
                destinationVC.cardSenderIsMainScene = false
            }
        }
        
        if segue.identifier == "editCardFromUser" {
            if let destinationNavController = segue.destination as? UINavigationController,
                let destinationVC = destinationNavController.viewControllers.first as?
                CardTemplateTableViewController {
                destinationVC.cardSenderIsMainScene = false
                destinationVC.card = selectedCard
            }
        }
        
    }
    
    func setupCardTableViewCell(_ cell: CardCollectionViewCell) {
        cell.layer.cornerRadius = 20.0
    }
    
    func refresh() {
        collectionView.reloadData()
    }
    
    func actionSheetSelected(cellButtonTapped: UIButton, cell: CardCollectionViewCell) {
        
        let alertController = UIAlertController(title: "Share Business Card", message: "", preferredStyle: .actionSheet)
        
        let iMessagesButton = UIAlertAction(title: "iMessage", style: .default) { (_) in
            guard let indexPath = self.collectionView.indexPath(for: cell),
                let card = PersonController.shared.currentPerson?.personalCards[indexPath.row] else { return }
            
            self.presentSMSInterface(for: card, with: cell)
        }
        
        let multiShareButton = UIAlertAction(title: "MultiPeer Connect", style: .default) { (_) in
            
            guard let indexPath = self.collectionView.indexPath(for: cell),
                let card = PersonController.shared.currentPerson?.personalCards[indexPath.row] else { return }
            
            self.selectedCard = card
            
            MultipeerController.shared.searchAction()
        }
        
        
        let emailButton = UIAlertAction(title: "Email", style: .default) { (_) in
            guard let card = UIViewToPNG.uiViewToPNG(for: cell) else { return }
            self.sendEmail(attachment: card)
        }
        
        let contactButton = UIAlertAction(title: "Add to contacts", style: .default) { (_) in
            self.addContact()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(iMessagesButton)
        alertController.addAction(multiShareButton)
        alertController.addAction(contactButton)
        alertController.addAction(cancelButton)
        alertController.addAction(emailButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentSMSUnavailableAlert() {
        let alertController = UIAlertController(title: "SMS Services Unavailable", message: "Download iMessages and try again", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func presentSMSInterface(for card: Card, with cell: CardCollectionViewCell) {
        guard MFMessageComposeViewController.canSendText(),
            let cardRecordID = card.ckRecordID,
            let message = MessageController.createMessage(with: cardRecordID, from: cell) else { presentSMSUnavailableAlert(); return }
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        composeVC.message = message
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func fetchPersonalCards() {
        self.collectionView.refreshControl?.beginRefreshing()
        
        CardController.shared.fetchPersonalCards { (success) in
            if success {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.collectionView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    func setupCardTableViewCellShadow(_ cell: CardCollectionViewCell) {
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 4
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowColor = UIColor.darkGray.cgColor
    }
    
    func setupCardTableViewCellBorderColor(_ cell: CardCollectionViewCell) {
        cell.layer.borderWidth = 10
        cell.layer.borderColor = UIColor.clear.cgColor
        
    }
    
    func tableViewBackgroundColor() {
        self.collectionView.backgroundColor = UIColor.lightGray
    }
}

extension UserProfileCollectionViewController {
    
    func didReceiveData(_ data: Data, from peerID: MCPeerID) {
        
        let alertController = UIAlertController(title: "Received Card", message: "You've received a Card. Would you like to accept it?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            MultipeerController.shared.receiveData(data, from: peerID)
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in
            // Completion stuff
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true) {}
    }
    
    func didDiscoverPeer(_ peerID: MCPeerID) {
        let title = "Discovered a Peer!"
        let message = "Would you like to connect with \(peerID.displayName)?"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            MultipeerController.shared.invitePeer(peerID)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func didReceiveInvitation(from peerID: MCPeerID, in session: MCSession, with invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let alert = UIAlertController(title: "Invitation for a business card", message: "from \(peerID.displayName)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default) { action in
            invitationHandler(true, session)
        })
        alert.addAction(UIAlertAction(title: "Decline", style: .cancel) { action in
            invitationHandler(false, session)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentSendCardAlert(for peerID: MCPeerID) {
        let alertController = UIAlertController(title: "Send Card", message: "Would you like to send the selected Card?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            MultipeerController.shared.sendData(to: peerID)
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true) {}
    }
    
    func presentUnableToSaveAlert(with completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Unable to Save Card", message: "This card already exists in your wallet", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (_) in
            completion()
        }
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true) { (success) in
            MultipeerController.shared.cancelSession()
        }
    }
    
    func presentFailedCardReceiveAlert() {
        let alertController = UIAlertController(title: "Failed to Receive Card", message: "The Card object could not be properly received", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true) { (success) in
            MultipeerController.shared.cancelSession()
        }
    }
}
