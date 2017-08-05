//
//  CardReceived.swift
//  ExecUDek
//
//  Created by Austin Money on 8/4/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import UIKit

@IBDesignable
class CardReceived: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    

}

extension CardReceived {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
