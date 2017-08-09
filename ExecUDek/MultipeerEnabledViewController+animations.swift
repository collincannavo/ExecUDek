//
//  MultipeerEnabledViewController+animations.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 8/9/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import SharedExecUDek

extension MultipeerEnabledViewController {
    
    
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
    
    func popCard(_ card: Card, cell: CardCollectionViewCell, from collectionView: UICollectionView) {
        yPositionAnimation(for: cell, withTranslation: -0.5 * cell.frame.size.height, duration: 0.3, startingTransform: CATransform3DIdentity) { (_) in
            self.bringForwardAnimation(for: cell, withScale: 1.08, zPosition: 1.0, duration: 0.2, shadowRadius: 5.0, shadowOpacity: 0.9, completion: { (_) in
                self.yPositionAnimation(for: cell,
                                        withTranslation: 0.5 * cell.frame.size.height,
                                        duration: 0.3,
                                        startingTransform: cell.layer.transform,
                                        completion: { (_) in
                                            
                                            collectionView.visibleCells.forEach({ (cell) in
                                                if let cardCell = cell as? CardCollectionViewCell {
                                                    cardCell.isUserInteractionEnabled = false
                                                }
                                            })
                                            
                                            cell.isCurrentlyFocused = true
                                            cell.isUserInteractionEnabled = true
                                            collectionView.bringSubview(toFront: cell)
                                            cell.shareButton.layer.transform = cell.layer.transform
                                            cell.bringSubview(toFront: cell.shareButton)
                                            
                                            if let indexPath = collectionView.indexPath(for: cell) {
                                                cell.returnIndex = indexPath.row
                                            }
                                            
                })
            })
        }
    }
    
    func returnCard(_ card: Card, cell: CardCollectionViewCell, to collectionView: UICollectionView) {
        if let returnIndex = cell.returnIndex {
            for i in returnIndex...collectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(row: i, section: 0)
                guard let newTopCell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell else { continue }
                collectionView.bringSubview(toFront: newTopCell)
            }
        }
        
        yPositionAnimation(for: cell, withTranslation: -0.5 * cell.frame.size.height, duration: 0.3, startingTransform: cell.layer.transform) { (_) in
            self.bringForwardAnimation(for: cell, withScale: 1 / 1.08, zPosition: -1.0, duration: 0.2, shadowRadius: 0.0, shadowOpacity: 0.0, completion: { (_) in
                self.yPositionAnimation(for: cell,
                                        withTranslation: 0.5 * cell.frame.size.height,
                                        duration: 0.3,
                                        startingTransform: cell.layer.transform,
                                        completion: { (_) in
                                            
                                            self.enableInteractionInVisibleCells(for: collectionView)
                                            
                                            cell.isCurrentlyFocused = false
                })
            })
        }
    }
    
    func enableInteractionInVisibleCells(for collectionView: UICollectionView) {
        collectionView.visibleCells.forEach({ (cell) in
            if let cardCell = cell as? CardCollectionViewCell {
                cardCell.isUserInteractionEnabled = true
            }
        })
    }
}
