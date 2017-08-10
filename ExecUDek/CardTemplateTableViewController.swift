//
//  CardTemplateTableViewController.swift
//  ExecUDek
//
//  Created by Arnold Mukasa on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import CloudKit
import SharedExecUDek
import ContactsUI

class CardTemplateTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, PhotoSelctorCellDelegate {

    //MARK: TableView TextField Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var cellTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var cardHeaderView: UIView!
    
    // MARK: UIView Label Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var addToContactsButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    // MARK: Properties
    var cardSenderIsMainScene: Bool = false
    var card: Card?
    var commonCardXIB: CardCollectionViewCell?
    var newContact: CNMutableContact?
    weak var delegate: PhotoSelectViewControllerDelegate?

    // MARK: IBAction Outlets
    @IBAction func cancelButtonTapped(_ sender: Any) {
        findAndResignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addToContactsTapped(_ sender: UIButton) {
        
        findAndResignFirstResponder()
        newContact = CNMutableContact()
        contactInput()
        guard let newContactUnwrapped = newContact else { return }
        let contactView = CNContactViewController(for: newContactUnwrapped)
        let navigationView = UINavigationController(rootViewController: contactView)
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(dismissView))
        contactView.navigationItem.leftBarButtonItem = dismissButton
        present(navigationView,animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        findAndResignFirstResponder()
        guard let email = emailTextField.text, !email.isEmpty else {
            if emailTextField.text == "" {
                saveCardToCloudKit { (success) in
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            return
        }
        if isValidEmail(stringValue: email) == true {
            saveCardToCloudKit { (success) in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
                presentAlert()
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        findAndResignFirstResponder()
        guard let card = card, let person = PersonController.shared.currentPerson else { return }
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        let indicatorView = ActivityIndicator.indicatorView(with: activityIndicator)
        activityIndicator.startAnimating()
        
        ActivityIndicator.addAndAnimateIndicator(indicatorView, to: view)
        
        PersonController.shared.deleteCard(card, from: person) { (success) in
            
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                ActivityIndicator.animateAndRemoveIndicator(indicatorView, from: self.view)
            }
            
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.presentFailedDeleteAlert()
            }
        }
    }
    
    // MARK: Private Methods
    fileprivate func presentAlert(){
        let alertController = UIAlertController(title: "Invalid email", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func isValidEmail(stringValue: String) ->Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailTest.evaluate(with: stringValue)
    }
    
    fileprivate func saveCardToCloudKit(with completion: @escaping (Bool) -> Void) {
        guard let name = nameTextField.text else { return }
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        let indicatorView = ActivityIndicator.indicatorView(with: activityIndicator)
        activityIndicator.startAnimating()
        ActivityIndicator.addAndAnimateIndicator(indicatorView, to: view)
        let title = titleTextField.text
        let cell = cellTextField.text
        let email = emailTextField.text
        let template = Template.one
        let address = addressTextField.text
        let logoImage = commonCardXIB?.photoButton.backgroundImage(for: UIControlState())?.fixOrientation() ?? UIImage()
        let logoData = UIImagePNGRepresentation(logoImage)
        switch (cardSenderIsMainScene, card == nil) {
        case (true, true):
            CardController.shared.createCardWith(cardData: nil, name: name, title: title, cell: cell, email: email, companyName: nil, note: nil, address: address, avatarData: nil, logoData: logoData, other: nil) { (success) in
                
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    ActivityIndicator.animateAndRemoveIndicator(indicatorView, from: self.view)
                }
                
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        case (false, true):
            CardController.shared.createPersonalCardWith(name: name, title: title, cell: cell, email: email, template: template, companyName: nil, note: nil, address: address, avatarData: nil, logoData: logoData, other: nil) { (success) in
                
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    ActivityIndicator.animateAndRemoveIndicator(indicatorView, from: self.view)
                }
                
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
            
        case (_, false):
            guard let card = card else { return }
            
            CardController.shared.updateCard(card, withCardData: nil, name: name, title: title, cell: cell, email: email, template: template, companyName: nil, note: nil, address: address, avatarData: nil, logoData: logoData, other: nil) { (success) in
                
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    ActivityIndicator.animateAndRemoveIndicator(indicatorView, from: self.view)
                }
                
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    fileprivate func updateViews() {
        nameTextField.text = card?.name
        titleTextField.text = card?.title
        emailTextField.text = card?.email
        cellTextField.text = card?.cell
        addressTextField.text = card?.address
        if !cardSenderIsMainScene {
            addToContactsButton.isHidden = true
            buttonsStackView.axis = .vertical
            buttonsStackView.alignment = .center
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            deleteButton.widthAnchor.constraint(equalTo: buttonsStackView.widthAnchor, multiplier: 0.5).isActive = true
        }
        navigationController?.navigationBar.barTintColor = UIColor(red: 113/255, green: 125/255, blue: 139/255, alpha: 1)
        let backgroundImage = UIImage(named: "skylineDarkened.png")
        let imageView = UIImageView(image: backgroundImage)
        imageView.frame = CGRect(x: 0, y: 0, width: 365, height: 645)
        self.tableView.backgroundView = imageView
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        cardHeaderView.layer.shadowOpacity = 1.0
        cardHeaderView.layer.shadowRadius = 4
        cardHeaderView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardHeaderView.layer.shadowColor = UIColor.black.cgColor
    }
    
    fileprivate func presentFailedDeleteAlert() {
        let alertController = UIAlertController(title: "Failed to Delete Card", message: "Could not successfully remove card from your account", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func setupTableViewGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(findAndResignFirstResponder))
        tableView.addGestureRecognizer(recognizer)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    fileprivate func contactInput(){
        newContact?.note = "ExecUDek App Business Card"
        if let name = nameTextField.text {
            newContact?.givenName = name
        }
        if let cell = cellTextField.text {
            let phone = CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue:cell))
            newContact?.phoneNumbers = [phone]
        }
        if let title = titleTextField.text {
            newContact?.jobTitle = title
        }
        if let website = websiteTextField.text {
            newContact?.organizationName = website
        }
        if let workAddress = addressTextField.text {
            let address = CNMutablePostalAddress()
            address.street = workAddress
        }
        if let email = emailTextField.text {
            let workEmail = CNLabeledValue(label:CNLabelWork, value: NSString(string: email))
            newContact?.emailAddresses = [workEmail]
        }
    }
    
    fileprivate func selectPhotoTapped(sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let alert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) -> Void in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) -> Void in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc fileprivate func dismissView(){
        dismiss(animated: true) {
            guard let newContact = self.newContact else { return }
            let store = CNContactStore()
            let request = CNSaveRequest()
            request.add(newContact, toContainerWithIdentifier: nil)
            do {
                try store.execute(request)
                print("New Contact created")
                self.newContact = nil
            } catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    fileprivate func textfieldReturnResponder(_ textField: UITextField){
        if textField == nameTextField {
            nameTextField.resignFirstResponder()
            titleTextField.becomeFirstResponder()
        } else if textField == titleTextField {
            titleTextField.resignFirstResponder()
            cellTextField.becomeFirstResponder()
        } else if textField == cellTextField {
            cellTextField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            emailTextField.resignFirstResponder()
            addressTextField.becomeFirstResponder()
        } else if textField == addressTextField {
            addressTextField.resignFirstResponder()
            websiteTextField.becomeFirstResponder()
        } else if textField == websiteTextField {
            websiteTextField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
    }
    
    func findAndResignFirstResponder() {
        view.endEditing(true)
    }
    
    fileprivate func setupCardDisplay() {
        if let windowWidth = UIApplication.shared.keyWindow?.frame.size.width {
            let headerHeight = windowWidth * 175.0 / 300.0
            cardHeaderView.frame = CGRect(x: 0.0, y: 0.0, width: windowWidth, height: headerHeight)
        }
        
        let bundle = Bundle(identifier: "com.ganleyApps.SharedExecUDek")
        if let customView = bundle?.loadNibNamed("CardCollectionViewCell", owner: self, options: nil)?.first as? CardCollectionViewCell {
            commonCardXIB = customView
            commonCardXIB?.hideEditButton()
            commonCardXIB?.delegate = self
            commonCardXIB?.card = card
            commonCardXIB?.updateViews()
            commonCardXIB?.hideShareButton()
            commonCardXIB?.hideShareImage()
            cardHeaderView.layer.cornerRadius = 12.0
            
            commonCardXIB?.bounds = cardHeaderView.bounds
            
            if let commonCardXIB = commonCardXIB, let view = commonCardXIB.view {
                
                view.translatesAutoresizingMaskIntoConstraints = false
                cardHeaderView.addSubview(view)
                
                let leadingConstraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: cardHeaderView, attribute: .leading, multiplier: 1.0, constant: 0.0)
                
                let trailingConstraint = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: cardHeaderView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
                
                let topConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: cardHeaderView, attribute: .top, multiplier: 1.0, constant: 0.0)
                let bottomConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: cardHeaderView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
                
                cardHeaderView.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
            }
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            delegate?.photoSelectViewControllerSelected(image)
            commonCardXIB?.photoButton.setTitle("", for: UIControlState())
            commonCardXIB?.photoButton.setBackgroundImage(image, for: UIControlState())
        }
    }
    
    // MARK: UITextfieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let name = nameTextField.text, !name.isEmpty,
            let cell = cellTextField.text,
            let title = titleTextField.text,
            let email = emailTextField.text else {return}
        commonCardXIB?.nameLabel.text = name
        commonCardXIB?.titleLabel.text = title
        commonCardXIB?.cellLabel.text = cell
        commonCardXIB?.emailLabel.text = email
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {return true}
        let lastText = (text as NSString).replacingCharacters(in: range, with: string) as String
        if cellTextField == textField {
            textField.text = lastText.format("(NNN) NNN-NNNN", oldString: text)
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textfieldReturnResponder(textField)
        return true
    }
    
    // MARK: SwipeGestureRecognizer Delegate
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe right")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        titleTextField.delegate = self
        cellTextField.delegate = self
        emailTextField.delegate = self
        addressTextField.delegate = self
        updateViews()
        setupCardDisplay()
        setupTableViewGestureRecognizer()
    }
    
    func photoSelectCellSelected(cellButtonTapped: UIButton) {
        selectPhotoTapped(sender: cellButtonTapped)
    }
}

protocol PhotoSelectViewControllerDelegate: class {
    func photoSelectViewControllerSelected(_ image: UIImage)
}


