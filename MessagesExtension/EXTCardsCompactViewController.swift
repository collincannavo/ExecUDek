//
//  EXTCardsCompactViewController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import Messages
import CloudKit
import SharedExecUDek
import NotificationCenter

class EXTCardsCompactViewController: UIViewController,  PhotoSelctorCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    var conversation: MSConversation?
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Constants.personalCardsFetchedNotification, object: nil)
        let bundle = Bundle(identifier: "com.ganleyApps.SharedExecUDek")
        let yourXIBName = UINib(nibName: "CardCollectionViewCell", bundle: bundle)
        
        collectionView.register(yourXIBName, forCellWithReuseIdentifier: "collectionCardCell")
        
        setupViews()
    }
    
    // MARK: - Collection view data source

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PersonController.shared.currentPerson?.personalCards.count ?? 0
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCardCell", for: indexPath) as? CardCollectionViewCell else { return CardCollectionViewCell() }
        
        let card = PersonController.shared.currentPerson?.personalCards[indexPath.row]
        
        cell.card = card
        cell.nameLabel.text = card?.name
        cell.enableEntireCardButton()
        cell.hideShareButton()
        cell.hideShareImage()
        cell.delegate = self
        guard let logoData = card?.logoData,
            let logoImage = UIImage(data: logoData) else { return cell }
        
        cell.photoButton.setImage(logoImage, for: .normal)
        cell.photoButton.setImage(logoImage, for: .disabled)
        cell.photoButton.setTitle("", for: .normal)
        
        setupCardTableViewCellShadow(cell)
        setupCardTableViewCellBorderColor(cell)
        
        return cell
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.frame.width
        
        return CGSize(width: collectionViewWidth, height: (collectionViewWidth * 0.518731988472622))
        
    }
    
    // MARK: - Photo selector cell delegate
    func entireCardWasTapped(card: Card, cell: CardCollectionViewCell) {
        guard let conversation = conversation,
            let cardRecordID = card.ckRecordID else { return }
        MessageController.prepareToSendCard(with: cardRecordID, from: cell, in: conversation)
    }
    
    // MARK: - Helper methods
    func refresh() {
        collectionView.reloadData()
    }
    
    func setupViews() {
        collectionView.backgroundColor = UIColor.lightGray
    }
    
    func setupCardTableViewCellShadow(_ cell: CardCollectionViewCell) {
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 5
        cell.layer.shadowOffset = CGSize(width: 0, height: 4)
        cell.layer.shadowColor = UIColor.darkGray.cgColor
    }
    
    func setupCardTableViewCellBorderColor(_ cell: CardCollectionViewCell) {
        cell.layer.borderWidth = 10
        cell.layer.borderColor = UIColor.clear.cgColor
        
    }
}
