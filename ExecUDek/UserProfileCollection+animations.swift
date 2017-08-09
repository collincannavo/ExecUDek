//
//  UserProfileCollection+animations.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 8/8/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import SharedExecUDek

extension UserProfileCollectionViewController {
    
    
    func yPositionAnimation(for cell: CardCollectionViewCell,
                            withTranslation translation: CGFloat,
                            duration: TimeInterval,
                            startingTransform: CATransform3D,
                            completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: duration, animations: { 
            
            cell.layer.transform = CATransform3DTranslate(startingTransform, 0.0, translation, 0.0)
            
        }, completion: completion)
    }
    
    func bringForwardAnimation(for cell: CardCollectionViewCell,
                               withScale scale: CGFloat,
                               zPosition: CGFloat,
                               duration: TimeInterval,
                               shadowRadius: CGFloat,
                               shadowOpacity: Float,
                               completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: duration, animations: { 
            
            let zPositionTransform = CATransform3DTranslate(cell.layer.transform, 0.0, 0.0, zPosition)
            let scaleTransform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.0)
            let combinedTransform = CATransform3DConcat(zPositionTransform, scaleTransform)
            
            cell.layer.shadowRadius = shadowRadius
            cell.layer.shadowOpacity = shadowOpacity
            
            cell.layer.transform = combinedTransform
            
        }, completion: completion)
    }
}
