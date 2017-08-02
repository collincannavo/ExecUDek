//
//  CardsViewController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import SharedExecUDek
import NotificationCenter

class CardsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cardSearchBar: UISearchBar!
    
    @IBAction func profileIconTapped(_ sender: Any) {
    }
    
    @IBAction func addCardButtonTapped(_ sender: Any) {
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    var selectedCard: Card?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        cardSearchBar.delegate = self
        cardSearchBar.returnKeyType = UIReturnKeyType.done
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Constants.cardsFetchedNotification, object: nil)
        
        let bundle = Bundle(identifier: "com.arnoldmukasa.SharedExecUDek")
        let cardXIB = UINib(nibName: "CommonCardTableViewCell", bundle: bundle)
        
        tableView.register(cardXIB, forCellReuseIdentifier: "cardCell")
    }
    
    // MARK: - Search bar delegate
    var inSearchMode = false
    var filteredData = [String]()
    var data = [String]()
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            inSearchMode = true
            filteredData = data.filter({$0 == searchBar.text})
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PersonController.shared.currentPerson?.cards.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = PersonController.shared.currentPerson?.cards[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as? CommonCardTableViewCell,
            let newCard = card
          
            else { return CommonCardTableViewCell()
        }
        
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
            cell.photoButton.setBackgroundImage(image, for: .disabled)
            cell.photoButton.setTitle("", for: .normal)
            
        }
        
        cell.hideShareButton()
        cell.disablePhotoButton()
        
        setupCardTableViewCell(cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell tapped! \n\n\n\n\n")
        
        guard let cell = tableView.cellForRow(at: indexPath) as? CommonCardTableViewCell else { return }
        
        if let card = cell.card {
            selectedCard = card
            
            performSegue(withIdentifier: "editCardFromMain", sender: nil)
        }
        
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCardFromMain" {
            if let destinationNavController = segue.destination as? UINavigationController,
                let destinationVC = destinationNavController.viewControllers.first as? CardTemplateTableViewController {
                destinationVC.cardSenderIsMainScene = true
            }
        }
        
        if segue.identifier == "editCardFromMain" {
            if let destinationNavController = segue.destination as? UINavigationController,
                let destinationVC = destinationNavController.viewControllers.first as? CardTemplateTableViewController {
                destinationVC.cardSenderIsMainScene = true
                destinationVC.card = selectedCard
            }
        }
    }
    
    // MARK: - Helper methods
    func setupCardTableViewCell(_ cell: CommonCardTableViewCell) {
        cell.layer.cornerRadius = 20.0
    }
    
    func refresh() {
        tableView.reloadData()
    }
}
