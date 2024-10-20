//
//  LockScreenWidgetBundle.swift
//  LockScreenWidget
//
//  Created by Eva Isabella Luna on 3/7/24.
//

import WidgetKit
import SwiftUI

@main
struct MalachiteWidgetBundle: WidgetBundle {
    var body: some Widget {
        LockScreenWidget()
        if #available(iOS 18.0, *) {
            ControlCenterWidget()
        }
    }
}
