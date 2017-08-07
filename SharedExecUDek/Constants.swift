//
//  Constants.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/30/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation

public struct Constants {
    public static let receivedCardRecordIDKey = "receivedCardRecordID"
    
    // Notification center notification names
    public static let cardsFetchedNotification: Notification.Name = Notification.Name(rawValue: "cardsFetched")
    public static let personalCardsFetchedNotification: Notification.Name = Notification.Name(rawValue: "personalCardsFetched")
    public static let multipeerNavBarItemTappedNotification: Notification.Name = Notification.Name(rawValue: "multipeerNavBarItemTapped")
    public static let advertiseMultipeerNotification: Notification.Name = Notification.Name(rawValue: "advertiseMultipeer")
    public static let endAdvertiseMultipeerNotification: Notification.Name = Notification.Name(rawValue: "endAdvertiseMultipeer")
}
