//
//  MalachiteIntentUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/1/24.
//

import AppIntents

@available(iOS 18.0, watchOS 9.0, *)
struct MalachiteLaunchIntent: AppIntent {
    static var title: LocalizedStringResource = "appname.open"
    static var description = IntentDescription("appname.open.description")
    static var openAppWhenRun: Bool = true
    @available(iOS 26.0, watchOS 26.0, *) static var supportedModes: IntentModes = .foreground(.immediate)
    
    @MainActor
    func perform() async throws -> some IntentResult { return .result() }
}

#if targetEnvironment(iOS)
@available(iOS 18.0, *)
struct MalachiteCaptureIntent: CameraCaptureIntent {
    typealias AppContext = MalachiteContext
    
    static let title: LocalizedStringResource = "appname.open"
    static let description = IntentDescription("appname.open.description")
    
    @MainActor
    func perform() async throws -> some IntentResult { return .result() }
}

struct MalachiteContext: Codable {
    // TODO
}
#endif
