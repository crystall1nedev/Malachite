//
//  LockScreenWidget.swift
//  LockScreenWidget
//
//  Created by Eva Isabella Luna on 3/7/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    // I need to learn more about WidgetKit to properly do this
    // however leaving Apple's default code in, and then customizing
    // the Static Configuration does what I want to do
    //
    // stubbing it breaks the icon so... idk i'll fix it later
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct LockScreenWidgetEntryView : View {
    var entry: Provider.Entry

        @Environment(\.widgetFamily)
        var family

        var body: some View {

            switch family {
            case .accessoryCircular:
                CircularWidgetView()
            default:
                // UI for Home Screen widget
                LockScreenWidgetEntryView(entry: entry)
            }
        }
}

struct LockScreenWidget: Widget {
    let kind: String = "LockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                LockScreenWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LockScreenWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Open Malachite")
        .description("Tap to quickly launch malachite from your lock screen.")
        .supportedFamilies([
            .accessoryCircular,
        ])
    }
}

struct CircularWidgetView: View {
    
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
