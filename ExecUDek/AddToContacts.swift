//
//  AddToContacts.swift
//  ExecUDek
//
//  Created by Arnold Mukasa on 8/3/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit
import ContactsUI

extension UserProfileCollectionViewController {
    func addContact(){
        let store = CNContactStore()
        let newContact = CNMutableContact()
        
        newContact.givenName = "Superman"
        newContact.familyName = "Spiderman"
        newContact.nickname = "Apple"
        
//        if let image = UIImage(named: "logo-apps-foundation.jpg"),
//            let data = UIImagePNGRepresentation(image){
//            newContact.imageData = data
//        }
        
        let phone = CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: "+441234567890"))
        newContact.phoneNumbers = [phone]
        
//        let email = CNLabeledValue(label: CNLabelWork, value: "contact@appsfoundation.com")
//        newContact.emailAddresses = [email]
        newContact.jobTitle = "iOS Developer"
        newContact.organizationName = "DevMountain"
        newContact.departmentName = "Mobile"
        
        let request = CNSaveRequest()
        request.add(newContact, toContainerWithIdentifier: nil)
        do {
            try store.execute(request)
            let alert = UIAlertController(title: "ExecUDek", message: "New contact has been created", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } catch let error{
            print(error)
        }
    }
}
