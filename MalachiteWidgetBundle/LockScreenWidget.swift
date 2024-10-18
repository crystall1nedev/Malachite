//
//  LockScreenWidget.swift
//  LockScreenWidget
//
//  Created by Eva Isabella Luna on 3/7/24.
//

import WidgetKit
import SwiftUI
import AppIntents

@available(iOS 16.0, *)
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry { SimpleEntry(date: Date()) }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {}

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {}
}

@available(iOS 16.0, *)
struct SimpleEntry: TimelineEntry { var date: Date }

@available(iOS 16.0, *)
struct LockScreenWidget: Widget {
    let kind: String = "LockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                LockScreenWidgetEntryView()
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LockScreenWidgetEntryView()
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Open Malachite")
        .description("Tap to quickly launch malachite from your lock screen.")
        .supportedFamilies([
            .accessoryCircular
        ])
    }
}

@available(iOS 16.0, *)
struct LockScreenWidgetEntryView : View {

        @Environment(\.widgetFamily)
        var family

        var body: some View {

            switch family {
            case .accessoryCircular:
                LockScreenCircularWidgetEntryView()
            default:
                LockScreenWidgetEntryView()
            }
        }
}

@available(iOS 16.0, *)
struct LockScreenCircularWidgetEntryView: View {
    
    var body: some View {
        if #available(iOS 17.0, *) {
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "camera.aperture")
            }
            .containerBackground(for: .widget) { }
        } else {
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "camera.aperture")
            }
            .padding()
            .background()
        }
    }
}
