//
//  UIViewToPNG.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/29/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import UIKit

public struct UIViewToPNG {
    public static func uiViewToPNG(for uiView: UIView) -> Data? {
        
        UIGraphicsBeginImageContextWithOptions(uiView.layer.frame.size, true, 1.0)
        guard let currentContext = UIGraphicsGetCurrentContext() else { return nil }
        uiView.layer.render(in: currentContext)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        
        return UIImagePNGRepresentation(image)
    }
}