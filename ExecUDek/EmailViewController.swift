//
//  EmailViewController.swift
//  ExecUDek
//
//  Created by Collin Cannavo on 8/1/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import MessageUI


extension UserProfileCollectionViewController {
    func sendEmail(attachment data: Data) {
        if MFMailComposeViewController.canSendMail() {
            let email = MFMailComposeViewController()
            let data = data
            email.mailComposeDelegate = self
            email.setSubject("")
            email.setToRecipients([""])
            email.setCcRecipients([""])
            email.setBccRecipients([""])
            email.setMessageBody("Here is my business card!", isHTML: true)
            email.addAttachmentData(data, mimeType: "image/png", fileName: "My_Business_Card")
            self.present(email, animated: true, completion: nil)
            
        } else {
            NSLog("This device cannot send email")
            print("This device cannot send email")
            let alertController = UIAlertController(title: "Is your Mail App on?", message: "Please ensure your Apple Mail app is active in your Settings", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .cancelled:
            NSLog("%@", "Email was cancelled")
            let alert = UIAlertController(title: "Your email has been saved", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        case .saved:
            NSLog("Email has been saved")
            let alert = UIAlertController(title: "Your email has been saved", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        case .failed:
            NSLog("Your email failed to send")
            let alert = UIAlertController(title: "Your email failed to send!", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        case .sent:
            NSLog("Your email has been sent!")
            let alert = UIAlertController(title: "Your email was sent successfully!", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
