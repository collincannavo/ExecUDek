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

class UserProfileCollectionViewController: MultipeerEnabledViewController, ActionSheetDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!

    let overlap: CGFloat = -120.0
    
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
            
            if cell.isCurrentlyFocused {
                returnCard(card, cell: cell, to: collectionView)
            } else {
                guard collectionView.numberOfItems(inSection: 0) > 1,
                    let indexPath = collectionView.indexPath(for: cell),
                    indexPath.row < (collectionView.numberOfItems(inSection: 0) - 1) else { return }
                popCard(card, cell: cell, from: collectionView)
            }
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
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Constants.personalCardsFetchedNotification, object: nil)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        checkForInitialLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
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
        return PersonController.shared.currentPerson?.sortedPersonalCards.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = PersonController.shared.currentPerson?.sortedPersonalCards[indexPath.row]
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
        if let data = card?.logoData,
            let image = UIImage(data: data) {
            
            cell.photoButton.setBackgroundImage(image.fixOrientation(), for: .disabled)
            cell.photoButton.setTitle("", for: .disabled)
        }
        
        cell.disablePhotoButton()
        
        setupCardTableViewCellShadow(cell)
        setupCardTableViewCellBorderColor(cell)
        setupCardTableViewCell(cell)
        
        collectionView.bringSubview(toFront: cell)
        
        cell.actionSheetDelegate = self
        
        //placeCardInOrder(forIndex: indexPath.row)
        
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
        activityIndicator.stopAnimating()
        ActivityIndicator.animateAndRemoveIndicator(indicatorView, from: self.view)
        collectionView.reloadData()
    }
    
    // MARK: Card cell action sheet delegate
    
    func actionSheetSelected(cellButtonTapped: UIButton, cell: CardCollectionViewCell) {
        
        let alertController = UIAlertController(title: "Share Business Card", message: "", preferredStyle: .actionSheet)
        
        let iMessagesButton = UIAlertAction(title: "iMessage", style: .default) { (_) in
            guard let indexPath = self.collectionView.indexPath(for: cell),
                let card = PersonController.shared.currentPerson?.sortedPersonalCards[indexPath.row] else { return }
            
            self.presentSMSInterface(for: card, with: cell)
        }
        
        let multiShareButton = UIAlertAction(title: "Connect with Nearby", style: .default) { (_) in
            
            guard let indexPath = self.collectionView.indexPath(for: cell),
                let card = PersonController.shared.currentPerson?.sortedPersonalCards[indexPath.row] else { return }
            
            self.selectedCard = card
            
            MultipeerController.shared.searchAction()
        }
        
        
        let emailButton = UIAlertAction(title: "Email", style: .default) { (_) in
            guard let card = UIViewToPNG.uiViewToPNG(for: cell) else { return }
            self.sendEmail(attachment: card)
        }
  
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(iMessagesButton)
        alertController.addAction(multiShareButton)
        alertController.addAction(cancelButton)
        alertController.addAction(emailButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func cardCellEditButtonWasTapped(cell: CardCollectionViewCell) {
        selectedCard = cell.card
        cell.isCurrentlyFocused = false
        enableInteractionInVisibleCells(for: collectionView)
        performSegue(withIdentifier: "editCardFromUser", sender: nil)
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
    
    func checkForInitialLoad() {
        guard let person = PersonController.shared.currentPerson else { return }
        
        if !person.initialCardsFetchComplete {
            activityIndicator.startAnimating()
            
            ActivityIndicator.addAndAnimateIndicator(indicatorView, to: view)
        } else {
            activityIndicator.stopAnimating()
            ActivityIndicator.animateAndRemoveIndicator(indicatorView, from: self.view)
        }
    }
    
    func setupCardTableViewCellShadow(_ cell: CardCollectionViewCell) {
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 4
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowColor = UIColor.black.cgColor
    }
    
    func setupCardTableViewCellBorderColor(_ cell: CardCollectionViewCell) {
        cell.layer.borderWidth = 10
        cell.layer.borderColor = UIColor.clear.cgColor
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let customCell = cell as? CardCollectionViewCell else { return }
        
        if indexPath.row % 3 == 0 {
            customCell.changeBackgroundToBlue()
        } else if indexPath.row % 3 == 1 {
            customCell.changeBackgroundToRed()
        } else if indexPath.row % 3 == 2 {
            customCell.changeBackgroundToOrange()
        }
        
        placeCardInOrder(forIndex: indexPath.row)
    }
    
    func placeCardInOrder(forIndex index: Int) {
        for i in index...(collectionView.numberOfItems(inSection: 0) - 1) {
            let indexPath = IndexPath(row: i, section: 0)
            guard let newTopCell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell else { continue }
            collectionView.bringSubview(toFront: newTopCell)
        }
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.left {
            print("Swipe left")
            self.dismiss(animated: true, completion: nil)
        }
    }
}
