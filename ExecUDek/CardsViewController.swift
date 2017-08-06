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

class CardsViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let overlap: CGFloat = -120.0
    
    // MARK: - Outlets
    
    @IBOutlet weak var cardSearchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    var selectedCard: Card?
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        cardSearchBar.delegate = self
        cardSearchBar.returnKeyType = UIReturnKeyType.done
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Constants.cardsFetchedNotification, object: nil)
        
        let bundle = Bundle(identifier: "com.ganleyApps.SharedExecUDek")
        let cardXIB = UINib(nibName: "CardCollectionViewCell", bundle: bundle)
        
        collectionView.register(cardXIB, forCellWithReuseIdentifier: "collectionCardCell")
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchCards), for: .valueChanged)
        collectionViewBackgroundColor()
        
    }
    
    // MARK: - Search bar delegate
    var inSearchMode = false
    var filteredData = [String]()
    var data = [String]()
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            view.endEditing(true)
            collectionView.reloadData()
        } else {
            inSearchMode = true
            filteredData = data.filter({$0 == searchBar.text})
            collectionView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PersonController.shared.currentPerson?.cards.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = PersonController.shared.currentPerson?.cards[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCardCell", for: indexPath) as? CardCollectionViewCell,
            let newCard = card
            
            else { return CardCollectionViewCell()
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
        cell.hideShareImage()
        cell.disablePhotoButton()
        
        setupCardTableViewCellShadow(cell)
        setupCardTableViewCellBorderColor(cell)
        
        collectionView.bringSubview(toFront: cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.frame.width
        
        return CGSize(width: collectionViewWidth, height: (collectionViewWidth * 0.518731988472622))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return overlap
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell else { return }
        
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
    
    func refresh() {
        collectionView.reloadData()
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
    
    func collectionViewBackgroundColor() {
        self.collectionView.backgroundColor = UIColor.lightGray
        
    }
    
    func fetchCards() {
        guard refreshControl.isRefreshing else { return }
        
        CloudKitContoller.shared.fetchCurrentUser { (success, currentPerson) in
            if success && (currentPerson != nil) {
                CardController.shared.fetchReceivedCards { (success) in
                    if success {
                        DispatchQueue.main.async {
                            self.refresh()
                            if self.refreshControl.isRefreshing { self.refreshControl.endRefreshing() }
                        }
                    }
                }
                
                CardController.shared.fetchPersonalCards(with: { (_) in })
            }
        }
    }
    
}
