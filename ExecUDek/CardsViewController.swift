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
    }
    
    // MARK: - Search bar delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
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
        case 1:
            guard let cardImage = UIImage(named: "businessCard2") else { return cell }
            cell.updateCell(withCardImage: cardImage)
        case 2:
            guard let cardImage = UIImage(named: "businessCard3") else { return cell }
            cell.updateCell(withCardImage: cardImage)
        default:
            return cell
        }
        
        setupCardTableViewCell(cell)
        
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - Helper methods
    func setupCardTableViewCell(_ cell: CardTableViewCell) {
        cell.layer.cornerRadius = 20.0
    }
}
