//
//  ActivityIndicator.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 8/9/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation

public struct ActivityIndicator {
    public static func indicatorView(with indicator: UIActivityIndicatorView) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60.0, height: 60.0))
        view.backgroundColor = UIColor(red: 113/255, green: 125/255, blue: 139/255, alpha: 1)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(indicator)
        
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }
    
    public static func addAndAnimateIndicator(_ indicatorView: UIView, to view: UIView) {
        indicatorView.alpha = 0.0
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicatorView)
        
        indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        indicatorView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        indicatorView.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        
        indicatorView.layer.cornerRadius = 16.0
        
        UIView.animate(withDuration: 0.1) {
            indicatorView.alpha = 1.0
        }
    }
    
    public static func animateAndRemoveIndicator(_ indicatorView: UIView, from view: UIView) {
        UIView.animate(withDuration: 0.1) {
            indicatorView.alpha = 0.0
        }
        
        indicatorView.removeFromSuperview()
    }
}
