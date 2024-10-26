//
//  ControlCenterWidgetControl.swift
//  ControlCenterWidget
//
//  Created by Eva Isabella Luna on 10/14/24.
//

import AppIntents
import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct ControlCenterWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "dev.crystall1ne.Malachite.ControlCenterWidget",
            provider: Provider()
        ) { value in
            ControlWidgetButton(action: MalachiteLaunchIntent()) {
                Label("appname.open", systemImage: "camera.aperture")
                    .controlWidgetActionHint("appname.open.action_button")
            }
            .tint(.green)
        }
        .displayName("appname.open")
        .description("appname.open.description")
    }
}

@available(iOS 18.0, *)
extension ControlCenterWidget {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            false
        }
    }
}

@available(iOS 18.0, *)
struct MalachiteLaunchIntent: AppIntent {
    static var title: LocalizedStringResource = "appname.open"
    static var description = IntentDescription("appname.open.description")
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult { return .result() }
}
