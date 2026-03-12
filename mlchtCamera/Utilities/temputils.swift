//
//  temputils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/29/25.
//

#warning("This entire file is to be refactored with MalachiteKit")

import Foundation
import UIKit

class temputils {
    struct notificationBuilder {
        let delegate: Any
        let name: NSNotification.Name
        let action: Selector
    }
}

final class CompanionState: ObservableObject {
    static let shared = CompanionState()
    @Published var isForeground: Bool = false
}
