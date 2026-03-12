//
//  Misc.swift
//  mlchtCamera
//
//  Created by Eva Isabella Luna on 3/12/26.
//

import SwiftUI

/// An extension that enables Notification posting and getting.
extension RawRepresentable where RawValue == String, Self: NotificationName {
    var name: Notification.Name {
        get { return Notification.Name(self.rawValue) }
    }
}

/// A protocol that enables Notification posting and getting.
protocol NotificationName {
    var name: Notification.Name { get }
}
