//
//  CardsViewController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

class CardsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cardSearchBar: UISearchBar!
    
    @IBAction func profileIconTapped(_ sender: Any) {
    }
    
    @IBAction func addCardButtonTapped(_ sender: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        cardSearchBar.delegate = self
        cardSearchBar.returnKeyType = UIReturnKeyType.done
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as? CardTableViewCell else {
            return CardTableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            guard let cardImage = UIImage(named: "businessCard1") else { return cell }
            cell.updateCell(withCardImage: cardImage)
            data.append("businessCard1")
        case 1:
            guard let cardImage = UIImage(named: "businessCard2") else { return cell }
            cell.updateCell(withCardImage: cardImage)
            data.append("businessCard2")
        case 2:
            guard let cardImage = UIImage(named: "businessCard3") else { return cell }
            cell.updateCell(withCardImage: cardImage)
            data.append("businessCard3")
        default:
            return cell
        }
        
        setupCardTableViewCell(cell)
        
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCardFromMain" {
            if let destinationVC = segue.destination as? CardTemplateTableViewController {
                destinationVC.cardSenderIsMainScene = true
            }
        }
        
        if segue.identifier == "editCardFromMain" {
            if let destinationVC = segue.destination as? CardTemplateTableViewController {
                destinationVC.cardSenderIsMainScene = true
            }
        }
    }
    
    // MARK: - Helper methods
    func setupCardTableViewCell(_ cell: CardTableViewCell) {
        cell.layer.cornerRadius = 20.0
    }
}
