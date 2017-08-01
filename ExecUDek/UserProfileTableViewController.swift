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

class UserProfileTableViewController: UITableViewController {
    
    var selectedCard: Card?

    @IBAction func addNewCardButtonTapped(_ sender: Any) {
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell tapped! \n\n\n\n\n")
        
        guard let cell = tableView.cellForRow(at: indexPath) as? CommonCardTableViewCell else { return }
        
        if let card = cell.card {
            selectedCard = card
            
            performSegue(withIdentifier: "editCardFromUser", sender: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Constants.personalCardsFetchedNotification, object: nil)

        let bundle = Bundle(identifier: "com.ganleyapps.SharedExecUDek")
        let cardXIB = UINib(nibName: "CommonCardTableViewCell", bundle: bundle)
        
        tableView.register(cardXIB, forCellReuseIdentifier: "cardCell")
        
        
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
            cell.cellLabel.text = "\(cellPhone)"
        }
        
        cell.nameLabel.text = newCard.name
        cell.titleLabel.text = newCard.title
        cell.emailLabel.text = newCard.email
        cell.card = newCard
        
        if let data = card?.logoData {
            let image = UIImage(data: data)
            
            cell.photoButton.setBackgroundImage(image, for: .normal)
            cell.photoButton.setTitle("", for: .normal)
            
        }
        setupCardTableViewCell(cell)
        
        return cell
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
}
