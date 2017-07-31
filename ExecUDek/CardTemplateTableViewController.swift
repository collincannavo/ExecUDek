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
        
        let bundle = Bundle(identifier: "com.ganleyapps.SharedExecUDek")
        if let customView = bundle?.loadNibNamed("CommonCardTableViewCell", owner: self, options: nil)?.first as? CommonCardTableViewCell {
            cardContentView.addSubview(customView)
            commonCardXIB = customView
            commonCardXIB?.delegate = self
        }
        
        guard let card = card else { return }
            updateViews()
    }
    
    // TableView TextFields
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var cellTextField: UITextField!
    @IBOutlet weak var officeNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    //@IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var cardContentView: UIView!
    @IBOutlet weak var websiteTextField: UITextField!
    
    // UIView Labels
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    
    // MARK: - Properties
    var cardSenderIsMainScene: Bool = false
    var card: Card?
    var commonCardXIB: CommonCardTableViewCell?
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveCardToCloudKit()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        
        if let card = card,
            let recordID = card.ckRecordID {
            
            CloudKitContoller.shared.deleteRecord(recordID: recordID)
        }
        self.dismiss(animated: true, completion: nil)
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
        nameLabel.text = name
        titleLabel.text = title
        cellLabel.text = cell
        emailLabel.text = email
        textField.resignFirstResponder()
        return true
    }
    
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
        if officeNumberTextField == textField {
            textField.text = lastText.format("(NNN) NNN-NNNN", oldString: text)
            return false
        }
        return true
    }
    
    // MARK: - Helper methods
    
    func saveCardToCloudKit() {
        
        guard let name = nameTextField.text else { return }
        
        let title = titleTextField.text
        let cell = Int(cellTextField.text ?? "")
        let email = emailTextField.text
        
        let officeNumber = Int(officeNumberTextField.text ?? "")
        let template = Template.one
        //let note = noteTextField.text
        let address = addressTextField.text
        let logoImage = commonCardXIB?.photoButton.backgroundImage(for: UIControlState()) ?? UIImage()
        let logoData = UIImagePNGRepresentation(logoImage)
        
        switch (cardSenderIsMainScene, card == nil) {
        case (true, true):
            CardController.shared.createCardWith(cardData: nil, name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, companyName: nil, note: nil, address: address, avatarData: nil, logoData: logoData, other: nil)
        case (false, true):
            CardController.shared.createPersonalCardWith(name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: nil, note: nil, address: address, avatarData: nil, logoData: logoData, other: nil)
        case (_, false):
            guard let card = card else { return }
            
            CardController.shared.updateCard(card, withCardData: nil, name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: nil, note: nil, address: address, avatarData: nil, logoData: logoData, other: nil)
        }
    }
    
    func updateViews() {
        nameTextField.text = card?.name
        titleTextField.text = card?.title
        emailTextField.text = card?.email
        if let officeNumber = card?.officeNumber { officeNumberTextField.text = "\(officeNumber)" }
        //noteTextField.text = card?.note
        addressTextField.text = card?.address
    }
    
    weak var delegate: PhotoSelectViewControllerDelegate?
}

// MARK:
protocol PhotoSelectViewControllerDelegate: class {
    func photoSelectViewControllerSelected(_ image: UIImage)
}


