//
//  CommonCardTableViewCell.swift
//  ExecUDek
//
//  Created by Collin Cannavo on 7/27/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit


class CommonCardTableViewCell: UITableViewCell {


    var card: Card?

    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBAction func addCompanyLogoButtonTapped(_ sender: Any) {
        guard let buttonTapped = sender as? UIButton else { return }
        delegate?.photoSelectCellSelected(cellButtonTapped: buttonTapped)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(withCardImage: UIImage) {
        guard let name = nameLabel.text,
            let title = titleLabel.text,
            let cell = cellLabel.text,
            let email = emailLabel.text
        else { return }
        
        let numberFormatter = NumberFormatter()
        let cellphone = numberFormatter.number(from: cell)
        
        card?.name = name
        card?.email = email
        card?.cell = cellphone as? Int
        card?.title = title
        
        
        
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        
        if textField == cellLabel {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = (newString as NSString).components(separatedBy: NSCharacterSet.decimalDigits.inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne {
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3 {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            
            if length - index > 3 {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            return false
        } else {
            return true
        }
    }
    
    weak var delegate: PhotoSelctorCellDelegate?
}


protocol PhotoSelctorCellDelegate : class {
    func photoSelectCellSelected(cellButtonTapped: UIButton)
}
