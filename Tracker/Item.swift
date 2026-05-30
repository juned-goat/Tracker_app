//
//  Item.swift
//  Tracker
//
//  Created by Juned Namaji on 30/05/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
