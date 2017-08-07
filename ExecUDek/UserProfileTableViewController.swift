//
//  UserProfileTableViewController.swift
//  ExecUDek
//
//  Created by Arnold Mukasa on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import SharedExecUDek
import NotificationCenter
import MultipeerConnectivity
import MessageUI

class UserProfileTableViewController: UITableViewController, ActionSheetDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MFMailComposeViewControllerDelegate, MCBrowserViewControllerDelegate {
    
    let session = MCSession(peer: MCPeerID(displayName: UIDevice.current.name), securityIdentity: nil, encryptionPreference: .none)
    var browser: MCNearbyServiceBrowser?
    var advertiser: MCNearbyServiceAdvertiser?
    var browserView: MCBrowserViewController!
    var card = CommonCardTableViewCell()
    
    var isMultipeerSender = false
    
    var selectedCard: Card?
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func multipeerButtonTapped(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Constants.multipeerNavBarItemTappedNotification, object: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? CommonCardTableViewCell else { return }
        
        if let card = cell.card {
            selectedCard = card
            
            performSegue(withIdentifier: "editCardFromUser", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Constants.personalCardsFetchedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startAdvertising), name: Constants.advertiseMultipeerNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelSession), name: Constants.endAdvertiseMultipeerNotification, object: nil)

        let bundle = Bundle(identifier: "com.ganleyApps.SharedExecUDek")
        let cardXIB = UINib(nibName: "CommonCardTableViewCell", bundle: bundle)
        
        tableView.register(cardXIB, forCellReuseIdentifier: "cardCell")
        
        self.session.delegate = self
        browserView = MCBrowserViewController(serviceType: "sending-card", session: session)
        browserView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: MCBrowserViewControllerDelegate
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserView.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserView.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return PersonController.shared.currentPerson?.personalCards.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = PersonController.shared.currentPerson?.personalCards[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as? CommonCardTableViewCell,
            let newCard = card else { return CommonCardTableViewCell() }
        
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
        
        return cell
    }
    
    // MARK: - MF message view controller delegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCardFromUser" {
            if let destinationNavController = segue.destination as? UINavigationController,
                let destinationVC = destinationNavController.viewControllers.first as? CardTemplateTableViewController {
                destinationVC.cardSenderIsMainScene = false
            }
        }
        if segue.identifier == "editCardFromUser" {
            if let destinationNavController = segue.destination as? UINavigationController,
                let destinationVC = destinationNavController.viewControllers.first as? CardTemplateTableViewController {
                destinationVC.cardSenderIsMainScene = false
                destinationVC.card = selectedCard
            }
        }
    }
    
    func setupCardTableViewCell(_ cell: CommonCardTableViewCell) {
        cell.layer.cornerRadius = 20.0
    }
    
    func refresh() {
        tableView.reloadData()
    }
    func actionSheetSelected(cellButtonTapped: UIButton, cell: CommonCardTableViewCell) {
        
        let alertController = UIAlertController(title: "Share Business Card", message: "", preferredStyle: .actionSheet)
        
        let iMessagesButton = UIAlertAction(title: "iMessage", style: .default) { (_) in
            guard let indexPath = self.tableView.indexPath(for: cell),
                let card = PersonController.shared.currentPerson?.personalCards[indexPath.row] else { return }
            
            self.presentSMSInterface(for: card, with: cell)
        }
        
        let multiShareButton = UIAlertAction(title: "MultiPeer Connect", style: .default) { (_) in

            guard let indexPath = self.tableView.indexPath(for: cell),
                let card = PersonController.shared.currentPerson?.personalCards[indexPath.row] else { return }
            
            self.selectedCard = card

            self.searchAction()
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
    
    func presentSMSInterface(for card: Card, with cell: CommonCardTableViewCell) {
        guard MFMessageComposeViewController.canSendText(),
            let cardRecordID = card.ckRecordID,
            let message = MessageController.createMessage(with: cardRecordID, from: cell) else { presentSMSUnavailableAlert(); return }
    
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        composeVC.message = message
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func fetchPersonalCards() {
        self.tableView.refreshControl?.beginRefreshing()
        
        CardController.shared.fetchPersonalCards { (success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    func setupCardTableViewCellShadow(_ cell: CommonCardTableViewCell) {
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 4
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowColor = UIColor.darkGray.cgColor
    }
    
    func setupCardTableViewCellBorderColor(_ cell: CommonCardTableViewCell) {
        cell.layer.borderWidth = 10
        cell.layer.borderColor = UIColor.clear.cgColor
        
    }
    
    func tableViewBackgroundColor() {
        self.tableView.backgroundColor = UIColor.lightGray
    }
}
