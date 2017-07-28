//
//  UserProfileTableViewController.swift
//  ExecUDek
//
//  Created by Arnold Mukasa on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class UserProfileTableViewController: UITableViewController {

    @IBAction func addNewCardButtonTapped(_ sender: Any) {
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return PersonController.shared.currentPerson?.personalCards.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userProfileCell", for: indexPath) as? UserProfileTableViewCell else {return UITableViewCell()}
        
        let card = PersonController.shared.currentPerson?.personalCards[indexPath.row]
        cell.card = card
        
        return cell
    }
}
