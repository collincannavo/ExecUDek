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

class EXTCardsCompactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PhotoSelctorCellDelegate {
    
    var conversation: MSConversation?
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: CardController.personalCardsFetchedNotification, object: nil)
        let bundle = Bundle(identifier: "com.ganleyapps.SharedExecUDek")
        let yourXIBName = UINib(nibName: "CommonCardTableViewCell", bundle: bundle)
        
        tableView.register(yourXIBName, forCellReuseIdentifier: "cardCell")
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PersonController.shared.currentPerson?.personalCards.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as? CommonCardTableViewCell else { return CommonCardTableViewCell() }
        
        let card = PersonController.shared.currentPerson?.personalCards[indexPath.row]
        
        cell.card = card
        cell.nameLabel.text = card?.name
        cell.enableEntireCardButton()
        cell.delegate = self
        guard let logoData = card?.logoData,
            let logoImage = UIImage(data: logoData) else { return cell }
        
        cell.photoButton.setImage(logoImage, for: UIControlState())
        
        return cell
    }
    
    // MARK: - Photo selector cell delegate
    func entireCardWasTapped(card: Card, cell: CommonCardTableViewCell) {
        guard let conversation = conversation,
            let cardRecordID = card.ckRecordID else { return }
        MessageController.prepareToSendCard(with: cardRecordID, from: cell, in: conversation)
    }
    
    // MARK: - Helper methods
    func refresh() {
        tableView.reloadData()
    }
}
