//
//  CardTemplateTableViewController.swift
//  ExecUDek
//
//  Created by Arnold Mukasa on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import CloudKit

class CardTemplateTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // TableView TextFields
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var cellTextField: UITextField!
    @IBOutlet weak var officeNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    //@IBOutlet weak var noteTextField: UITextField!
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
    
    @IBAction func selectPhotoTapped(_ sender: UIButton) {
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
            photoButton.setTitle("", for: UIControlState())
            photoButton.setBackgroundImage(image, for: UIControlState())
        }
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
        
        switch (cardSenderIsMainScene, card == nil) {
        case (true, true):
            CardController.shared.createCardWith(cardData: nil, name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, companyName: nil, note: nil, address: address, avatarData: nil, logoData: nil, other: nil)
        case (false, true):
            CardController.shared.createPersonalCardWith(name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: nil, note: nil, address: address, avatarData: nil, logoData: nil, other: nil)
        case (_, false):
            guard let card = card else { return }
            
            CardController.shared.updateCard(card, withCardData: nil, name: name, title: title, cell: cell, officeNumber: officeNumber, email: email, template: template, companyName: nil, note: nil, address: address, avatarData: nil, logoData: nil, other: nil)
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


