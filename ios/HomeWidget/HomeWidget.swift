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
        let textFromFlutterApp = userDefaults?.string(forKey: "text_from_app") ?? "Loading..."
        return SimpleEntry(
            date: Date(),
            text: textFromFlutterApp,
            temperature: 25,
            condition: "Loading",
            emoji: "⏳"
        )
    }

    private func fetchWeatherData() -> SimpleEntry {
        // API呼び出し（同期的なシミュレーション）
        let weatherData = [
            ("Sunny", "☀️", 25),
            ("Cloudy", "☁️", 22),
            ("Rainy", "🌧️", 18),
            ("Snowy", "❄️", 2),
            ("Partly Cloudy", "⛅", 24),
            ("Thunderstorm", "⛈️", 20)
        ]

        let randomWeather = weatherData.randomElement() ?? ("Sunny", "☀️", 25)
        let condition = randomWeather.0
        let emoji = randomWeather.1
        let baseTemp = randomWeather.2
        let temp = baseTemp + Int.random(in: -3...3) // 少し温度を変動

        let weatherText = "\(condition) \(temp)°C"

        // UserDefaultsに保存（Flutterアプリと共有）
        let userDefaults = UserDefaults(suiteName: "group.homeWidgetSandbox")
        userDefaults?.set(weatherText, forKey: "text_from_app")

        return SimpleEntry(
            date: Date(),
            text: weatherText,
            temperature: temp,
            condition: condition,
            emoji: emoji
        )
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

            let entry = SimpleEntry(
                date: Date(),
                text: weatherText,
                temperature: temp,
                condition: condition,
                emoji: "☀️"
            )
            completion(entry)
        }.resume()
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), text: "Loading...", temperature: 25, condition: "Sunny", emoji: "☀️")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = fetchWeatherData()
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
    let temperature: Int
    let condition: String
    let emoji: String
}

struct HomeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // 美しいグラデーション背景
            backgroundGradient(for: entry.condition)
                .overlay(
                    // 軽いオーバーレイで読みやすさを向上
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.black.opacity(0.2))
                )

            // メインコンテンツ
            VStack(spacing: 0) {
                // 上部: 天気アイコンと温度
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.emoji)
                            .font(.system(size: 36))
                            .shadow(radius: 2)

                        Text(entry.condition)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    }

                    Spacer()

                    // 大きな温度表示
                    VStack(alignment: .trailing, spacing: -2) {
                        Text("\(entry.temperature)")
                            .font(.system(size: 34, weight: .thin, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        Text("°C")
                            .font(.system(size: 16, weight: .light))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                // 下部: 更新時間とデコレーション
                HStack {
                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)
                        .shadow(color: .green, radius: 2)

                    Text(formattedTime(entry.date))
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.8))
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)

                    Spacer()

                    // 小さなデコレーション
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(.white.opacity(0.6))
                                .frame(width: 3, height: 3)
                                .shadow(color: .black.opacity(0.3), radius: 0.5)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }

    private func backgroundGradient(for condition: String) -> LinearGradient {
        switch condition {
        case "Sunny":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.8, blue: 0.4),
                    Color(red: 1.0, green: 0.6, blue: 0.2),
                    Color(red: 0.9, green: 0.4, blue: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Cloudy", "Partly Cloudy":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.7, green: 0.8, blue: 0.9),
                    Color(red: 0.5, green: 0.6, blue: 0.8),
                    Color(red: 0.4, green: 0.5, blue: 0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Rainy":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.3, green: 0.4, blue: 0.7),
                    Color(red: 0.2, green: 0.3, blue: 0.6),
                    Color(red: 0.1, green: 0.2, blue: 0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Snowy":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.9, green: 0.95, blue: 1.0),
                    Color(red: 0.8, green: 0.9, blue: 0.95),
                    Color(red: 0.7, green: 0.8, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Thunderstorm":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.3, blue: 0.5),
                    Color(red: 0.3, green: 0.2, blue: 0.4),
                    Color(red: 0.2, green: 0.1, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.7, blue: 1.0),
                    Color(red: 0.3, green: 0.6, blue: 0.9),
                    Color(red: 0.2, green: 0.5, blue: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
    SimpleEntry(date: .now, text: "Sunny 25°C", temperature: 25, condition: "Sunny", emoji: "☀️")
    SimpleEntry(date: .now, text: "Rainy 18°C", temperature: 18, condition: "Rainy", emoji: "🌧️")
}
