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

class EXTCardsCompactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EXTCardTableViewCellDelegate {
    
    var conversation: MSConversation?

    let cardImages = ["businessCard1", "businessCard2", "businessCard3"]
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "extCardCell", for: indexPath) as? EXTCardTableViewCell,
            let cardImage = UIImage(named: cardImages[indexPath.row]) else { return EXTCardTableViewCell() }
        
        cell.delegate = self
        cell.updateCell(with: cardImage)
        return cell
    }
    
    // MARK: - EXT card table view cell delegate
    func extCardPhotoWasTapped(photoData: Data) {
        guard let conversation = conversation else { return }
        //MessageController.prepareToSendPNG(with: photoData, in: conversation)
        MessageController.prepardToSendCard(with: CKRecord(recordType: "Test").recordID, in: conversation)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}