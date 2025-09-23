//
//  HomeWidget.swift
//  HomeWidget
//
//  Created by 稲山千穂 on 2025/09/23.
//

import WidgetKit
import SwiftUI
import Foundation

struct Provider: TimelineProvider {
    private func getDataFromFlutter() -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: "group.homeWidgetSandbox")
        let textFromFlutterApp = userDefaults?.string(forKey: "text_from_app") ?? "0"
        return SimpleEntry(date: Date(), text: textFromFlutterApp)
    }

    private func fetchWeatherData() -> SimpleEntry {
        // API呼び出し（同期的なシミュレーション）
        let temperatures = [15, 18, 22, 25, 28, 30, 32]
        let conditions = ["Sunny", "Cloudy", "Rainy", "Snowy"]

        let temp = temperatures.randomElement() ?? 20
        let condition = conditions.randomElement() ?? "Sunny"

        let weatherText = "\(condition) \(temp)°C"

        // UserDefaultsに保存（Flutterアプリと共有）
        let userDefaults = UserDefaults(suiteName: "group.homeWidgetSandbox")
        userDefaults?.set(weatherText, forKey: "text_from_app")

        return SimpleEntry(date: Date(), text: weatherText)
    }

    private func fetchWeatherDataAsync(completion: @escaping (SimpleEntry) -> Void) {
        // 実際のAPI呼び出し用の非同期関数（将来の拡張用）
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1") else {
            completion(fetchWeatherData()) // フォールバック
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("API Error: \(error)")
                completion(self.fetchWeatherData()) // フォールバック
                return
            }

            // API成功時のデータ処理（現在はシミュレーション）
            let temperatures = [15, 18, 22, 25, 28, 30, 32]
            let conditions = ["Sunny", "Cloudy", "Rainy", "Snowy"]

            let temp = temperatures.randomElement() ?? 20
            let condition = conditions.randomElement() ?? "Sunny"

            let weatherText = "\(condition) \(temp)°C (API)"

            let userDefaults = UserDefaults(suiteName: "group.homeWidgetSandbox")
            userDefaults?.set(weatherText, forKey: "text_from_app")

            let entry = SimpleEntry(date: Date(), text: weatherText)
            completion(entry)
        }.resume()
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), text: "0")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getDataFromFlutter()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // 現在のエントリ（新しい天気データを生成）
        let currentEntry = fetchWeatherData()
        entries.append(currentEntry)

        // 15分後の更新をスケジュール
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!

        let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
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
