//
//  HomeWidget.swift
//  HomeWidget
//
//  Created by 稲山千穂 on 2025/09/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    private func getDataFromFlutter() -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: "group.homeWidgetSandbox")
        let textFromFlutterApp = userDefaults?.string(forKey: "text_from_app") ?? "0"
        return SimpleEntry(date: Date(), text: textFromFlutterApp)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), text: "0")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getDataFromFlutter()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getDataFromFlutter()

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let text: String
}

struct HomeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.text)
    }
}

struct HomeWidget: Widget {
    let kind: String = "HomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                HomeWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                HomeWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    HomeWidget()
} timeline: {
    SimpleEntry(date: .now, text: "0")
    SimpleEntry(date: .now, text: "0")
}
