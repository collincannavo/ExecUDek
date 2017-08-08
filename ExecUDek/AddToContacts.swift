//
//  AddToContacts.swift
//  ExecUDek
//
//  Created by Arnold Mukasa on 8/3/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import Contacts

extension UserProfileCollectionViewController {
    func addContact(){
        let store = CNContactStore()
        let newContact = CNMutableContact()
        let contact = selectedCard
        if let name = contact?.name {
            newContact.givenName = name
        }
        if let cell = contact?.cell {
            let phone = CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue:cell))
            newContact.phoneNumbers = [phone]
        }
        if let title = contact?.title {
            newContact.jobTitle = title
        }
        if let company = contact?.companyName {
            newContact.organizationName = company
        }
        if let homeAddress = contact?.address {
            let address = CNMutablePostalAddress()
            address.street = homeAddress
        }
        if let email = contact?.email {
            let workEmail = CNLabeledValue(label:CNLabelWork, value: NSString(string: email))
            newContact.emailAddresses = [workEmail]
        }
        if let imageData = contact?.logoData {
            newContact.imageData = imageData
        }
        newContact.note = "Business Card"

        let request = CNSaveRequest()
        request.add(newContact, toContainerWithIdentifier: nil)
        do {
            try store.execute(request)
            guard let name = contact?.name else {return}
            let alert = UIAlertController(title: "ExecUDek", message: "\(name) Contact has been created", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } catch let error{
            print(error)
        }
    }
}
