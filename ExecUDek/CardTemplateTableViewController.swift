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

class CardTemplateTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, PhotoSelctorCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        titleTextField.delegate = self
        cellTextField.delegate = self
        emailTextField.delegate = self
        officeNumberTextField.delegate = self
        updateViews()
        setupCardDisplay()
        navigationController?.navigationBar.barTintColor = UIColor(red: 113/255, green: 125/255, blue: 139/255, alpha: 1)
        
    }

    // TableView TextFields
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var cellTextField: UITextField!
    @IBOutlet weak var officeNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    //@IBOutlet weak var cardContentView: UIView!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var cardHeaderView: UIView!
    
    // UIView Labels
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    
    // MARK: - Properties
    var cardSenderIsMainScene: Bool = false
    var card: Card?
    var commonCardXIB: CardCollectionViewCell?
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addToContactsTapped(_ sender: UIButton) {
            let store = CNContactStore()
            let newContact = CNMutableContact()
            if let name = nameTextField.text {
                newContact.givenName = name
            }
            if let cell = cellTextField.text {
                let phone = CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue:cell))
                newContact.phoneNumbers = [phone]
            }
            if let title = titleTextField.text {
                newContact.jobTitle = title
            }
            if let company = websiteTextField.text {
                newContact.organizationName = company
            }
            if let workAddress = addressTextField.text {
                let address = CNMutablePostalAddress()
                address.street = workAddress
            }
            if let email = emailTextField.text {
                let workEmail = CNLabeledValue(label:CNLabelWork, value: NSString(string: email))
                newContact.emailAddresses = [workEmail]
            }
            if let image = photoButton.imageView?.image, let imageData = UIImagePNGRepresentation(image) {
                newContact.imageData = imageData
            }
            newContact.note = "ExecUDek App Business Card"
            
            let request = CNSaveRequest()
            request.add(newContact, toContainerWithIdentifier: nil)
            do {
                try store.execute(request)
                guard let name = nameTextField.text else {return}
                let alert = UIAlertController(title: "ExecUDek", message: "\(name) Contact has been created", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            } catch let error{
                print(error)
            }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
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
        
        guard let card = card, let person = PersonController.shared.currentPerson else { return }
        
        PersonController.shared.deleteCard(card, from: person) { (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.presentFailedDeleteAlert()
            }
        }
    }
    
    func photoSelectCellSelected(cellButtonTapped: UIButton) {
        selectPhotoTapped(sender: cellButtonTapped)
    }
    
    func selectPhotoTapped(sender: UIButton) {
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let name = nameTextField.text, !name.isEmpty,
                    let cell = cellTextField.text,
                    let title = titleTextField.text,
                    let email = emailTextField.text else {return false}
        commonCardXIB?.nameLabel.text = name
        commonCardXIB?.titleLabel.text = title
        commonCardXIB?.cellLabel.text = cell
        commonCardXIB?.emailLabel.text = email
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Text
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
        if officeNumberTextField == textField {
            textField.text = lastText.format("(NNN) NNN-NNNN", oldString: text)
            return false
        }
        return true
    }
 
    // MARK: - Helper methods
    
    func presentAlert(){
        let alertController = UIAlertController(title: "Invalid email", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func isValidEmail(stringValue: String) ->Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailTest.evaluate(with: stringValue)
    }
    
    func saveCardToCloudKit(with completion: @escaping (Bool) -> Void) {
        
        guard let name = nameTextField.text else { return }
        
        let title = titleTextField.text
        let cell = cellTextField.text
        let email = emailTextField.text
        let officeNumber = officeNumberTextField.text
        let template = Template.one
        let address = addressTextField.text
        let logoImage = commonCardXIB?.photoButton.backgroundImage(for: UIControlState())?.fixOrientation() ?? UIImage()
        let logoData = UIImagePNGRepresentation(logoImage)
        
        switch (cardSenderIsMainScene, card == nil) {
        case (true, true):
            CardController.shared.createCardWith(cardData: nil, name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, companyName: nil, note: nil, address: address, avatarData: nil, logoData: logoData, other: nil) { (success) in
            
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        case (false, true):
            CardController.shared.createPersonalCardWith(name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: nil, note: nil, address: address, avatarData: nil, logoData: logoData, other: nil) { (success) in
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
            
        case (_, false):
            guard let card = card else { return }
            
            CardController.shared.updateCard(card, withCardData: nil, name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: nil, note: nil, address: address, avatarData: nil, logoData: logoData, other: nil) { (success) in
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func updateViews() {
        nameTextField.text = card?.name
        titleTextField.text = card?.title
        emailTextField.text = card?.email
        officeNumberTextField.text = card?.officeNumber
        cellTextField.text = card?.cell
        addressTextField.text = card?.address
    }
    
    func presentFailedDeleteAlert() {
        let alertController = UIAlertController(title: "Failed to Delete Card", message: "Could not successfully remove card from your account", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setupCardDisplay() {
        if let windowWidth = UIApplication.shared.keyWindow?.frame.size.width {
            let headerHeight = windowWidth * 175.0 / 300.0
            cardHeaderView.frame = CGRect(x: 0.0, y: 0.0, width: windowWidth, height: headerHeight)
        }
        
        let bundle = Bundle(identifier: "com.ganleyApps.SharedExecUDek")
        if let customView = bundle?.loadNibNamed("CardCollectionViewCell", owner: self, options: nil)?.first as? CardCollectionViewCell {
            commonCardXIB = customView
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
    
    weak var delegate: PhotoSelectViewControllerDelegate?
    
//    func collectionView(_ headerView: UITableViewHeaderFooterView) -> CGSize {
//        
//        let headerViewWidth = headerView.frame.width
//        
//        return CGSize(width: headerViewWidth, height: (headerViewWidth * 0.518731988472622))
//        
//    }
}

// MARK:
protocol PhotoSelectViewControllerDelegate: class {
    func photoSelectViewControllerSelected(_ image: UIImage)
}


