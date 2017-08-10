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

class CardsViewController: MultipeerEnabledViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ActionSheetDelegate {
    
    var filteredCardsArray: [Card] = []
    
    let overlap: CGFloat = -120.0
    
    // MARK: - Outlets
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    @IBAction func multipeerButtonTapped(_ sender: UIBarButtonItem) {
        customNavigationController.confirmChangeOfMultipeer()
    }
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Constants.cardsFetchedNotification, object: nil)
        
        
        let bundle = Bundle(identifier: "com.ganleyApps.SharedExecUDek")
        let cardXIB = UINib(nibName: "CardCollectionViewCell", bundle: bundle)
        
        collectionView.register(cardXIB, forCellWithReuseIdentifier: "collectionCardCell")
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchCards), for: .valueChanged)
        
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        checkForInitialLoad()
    }
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PersonController.shared.currentPerson?.sortedCards.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = PersonController.shared.currentPerson?.sortedCards[indexPath.row]
        
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
        
        if let data = card?.logoData,
            let image = UIImage(data: data) {
            
            cell.photoButton.setBackgroundImage(image.fixOrientation(), for: .normal)
            cell.photoButton.setBackgroundImage(image.fixOrientation(), for: .disabled)
            cell.photoButton.setTitle("", for: .normal)
            
        }
        
        cell.disablePhotoButton()
        
        setupCardTableViewCellShadow(cell)
        setupCardTableViewCellBorderColor(cell)
        
        collectionView.bringSubview(toFront: cell)
        
        cell.actionSheetDelegate = self
        
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
            
            if cell.isCurrentlyFocused {
                returnCard(card, cell: cell, to: collectionView)
            } else {
                guard collectionView.numberOfItems(inSection: 0) > 1,
                    let indexPath = collectionView.indexPath(for: cell),
                    indexPath.row < (collectionView.numberOfItems(inSection: 0) - 1) else { return }
                popCard(card, cell: cell, from: collectionView)
            }
        }
    }
    
    // Card cell action sheet delegate
    func actionSheetSelected(cellButtonTapped: UIButton, cell: CardCollectionViewCell) {}
    
    func cardCellEditButtonWasTapped(cell: CardCollectionViewCell) {
        selectedCard = cell.card
        cell.isCurrentlyFocused = false
        enableInteractionInVisibleCells(for: collectionView)
        performSegue(withIdentifier: "editCardFromMain", sender: nil)
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
        activityIndicator.stopAnimating()
        ActivityIndicator.animateAndRemoveIndicator(indicatorView, from: self.view)
        if self.refreshControl.isRefreshing { self.refreshControl.endRefreshing() }
        
        collectionView.reloadData()
    }
    
    func setupCardTableViewCellShadow(_ cell: CardCollectionViewCell) {
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 4
        cell.layer.shadowOffset = CGSize(width: 0, height: 4)
        cell.layer.shadowColor = UIColor.black.cgColor
    }
    
    func setupCardTableViewCellBorderColor(_ cell: CardCollectionViewCell) {
        cell.layer.borderWidth = 10
        cell.layer.borderColor = UIColor.clear.cgColor
        
    }
    
    //    func collectionViewBackgroundColor() {
    //        self.collectionView.backgroundColor = UIColor.lightGray
    //
    //    }
    
    func fetchCards() {
        guard refreshControl.isRefreshing else { return }
        
        activityIndicator.startAnimating()
        
        ActivityIndicator.addAndAnimateIndicator(indicatorView, to: view)
        
        CloudKitContoller.shared.fetchCurrentUser { (success, currentPerson) in
            if success && (currentPerson != nil) {
                CardController.shared.fetchReceivedCards { (success) in
                    if success {
                        DispatchQueue.main.async {
                            self.refresh()
                        }
                    }
                    DispatchQueue.main.async {                        
                        self.activityIndicator.stopAnimating()
                        ActivityIndicator.animateAndRemoveIndicator(self.indicatorView, from: self.view)
                        if self.refreshControl.isRefreshing { self.refreshControl.endRefreshing() }
                    }
                }
                
                CardController.shared.fetchPersonalCards(with: { (_) in })
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let customCell = cell as? CardCollectionViewCell else { return }
        
        if indexPath.row % 3 == 0 {
            customCell.changeBackgroundToBlue()
        } else if indexPath.row % 3 == 1 {
            customCell.changeBackgroundToRed()
        } else if indexPath.row % 3 == 2 {
            customCell.changeBackgroundToOrange()
        }
    }
    
    func checkForInitialLoad() {
        guard let person = PersonController.shared.currentPerson else { return }
        
        if !person.initialCardsFetchComplete {
            activityIndicator.startAnimating()
            
            ActivityIndicator.addAndAnimateIndicator(indicatorView, to: view)
        } else {
            activityIndicator.stopAnimating()
            ActivityIndicator.animateAndRemoveIndicator(indicatorView, from: self.view)
        }
    }
    
    let appBlue = UIColor(red: 32/255, green: 195/255, blue: 224/255, alpha: 1)
    let appRed = UIColor(red: 251/255, green: 100/255, blue: 112/255, alpha: 1)
    let appOrange = UIColor(red: 251/255, green: 191/255, blue: 88/255, alpha: 1)
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe Right")
            self.performSegue(withIdentifier: "toMyCards", sender: self)
        } else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            print("Swipe left")
            self.performSegue(withIdentifier: "addCardFromMain", sender: self)
        }
    }
}
