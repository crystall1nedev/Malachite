//
//  temputils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/29/25.
//

#warning("This entire file is to be refactored with MalachiteKit")

import Foundation
import LinkPresentation
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

/// Function to convert raw data into a sharable object for UIActivityViewController
final class dataToShareable: NSObject, UIActivityItemSource {
    let data: Data
    let title: String
    
    init(data: Data, title: String) throws {
        self.title = title
        self.data = data
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        data
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        data
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        return metadata
    }
}
