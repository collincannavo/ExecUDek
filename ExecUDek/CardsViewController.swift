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

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        cardSearchBar.delegate = self
        cardSearchBar.returnKeyType = UIReturnKeyType.done
        
        let yourXIBName = UINib(nibName: "CommonCardTableViewCell", bundle: nil)
        tableView.register(yourXIBName, forCellReuseIdentifier: "cardCell")
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as? CommonCardTableViewCell else {
            return CommonCardTableViewCell()
        }
        let card = PersonController.shared.currentPerson?.cards[indexPath.row]
        cell.nameLabel.text = card?.name
        
        setupCardTableViewCell(cell)
        
        return cell
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
            }
        }
    }
    
    // MARK: - Helper methods
    func setupCardTableViewCell(_ cell: CommonCardTableViewCell) {
        cell.layer.cornerRadius = 20.0
    }
}
