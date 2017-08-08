//
//  ConnectionStatus.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 8/7/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation

enum ConnectionStatus: String {
    case notConnected = "Not connected"
    case browsing = "Browsing..."
    case advertising = "Advertising..."
    case connecting = "Connecting..."
    case connected = "Connected"
}
