package com.example.home_widget_sandbox

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.SharedPreferences
import kotlin.random.Random

class HomeWidget : AppWidgetProvider() {

    private fun generateWeatherData(context: Context): WeatherData {
        // API呼び出しのシミュレーション
        val weatherOptions = arrayOf(
            WeatherData("Sunny", "☀️", 25),
            WeatherData("Cloudy", "☁️", 22),
            WeatherData("Rainy", "🌧️", 18),
            WeatherData("Snowy", "❄️", 2),
            WeatherData("Partly Cloudy", "⛅", 24),
            WeatherData("Thunderstorm", "⛈️", 20)
        )

        val weather = weatherOptions.random()
        val tempVariation = (-3..3).random()
        val finalTemp = weather.temperature + tempVariation

        val finalWeather = weather.copy(temperature = finalTemp)
        val weatherText = "${finalWeather.condition} ${finalWeather.temperature}°C"

        // SharedPreferencesに保存
        val sharedPref = context.getSharedPreferences("group.homeWidgetSandbox", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putString("text_from_app", weatherText)
            apply()
        }

        return finalWeather
    }

    data class WeatherData(
        val condition: String,
        val emoji: String,
        val temperature: Int
    )

    // 実際のAPI呼び出し用関数（将来の拡張用）
    private fun fetchWeatherFromAPI(context: Context, callback: (String) -> Unit) {
        // 実際の実装では、ここでHTTPリクエストを行う
        // 現在はシミュレーション

        try {
            // API呼び出しのシミュレーション
            val temperatures = arrayOf(15, 18, 22, 25, 28, 30, 32)
            val conditions = arrayOf("Sunny", "Cloudy", "Rainy", "Snowy")

            val temp = temperatures.random()
            val condition = conditions.random()

            val weatherText = "$condition ${temp}°C (API)"

            // SharedPreferencesに保存
            val sharedPref = context.getSharedPreferences("group.homeWidgetSandbox", Context.MODE_PRIVATE)
            with(sharedPref.edit()) {
                putString("text_from_app", weatherText)
                apply()
            }

            callback(weatherText)
        } catch (e: Exception) {
            // エラー時のフォールバック
            callback("Weather unavailable")
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        // 新しい天気データを生成
        val weatherData = generateWeatherData(context)

        // ウィジェットのビューを更新
        val views = RemoteViews(context.packageName, R.layout.home_widget)

        // 各ビュー要素を個別に設定
        views.setTextViewText(R.id.weather_emoji, weatherData.emoji)
        views.setTextViewText(R.id.temperature_text, weatherData.temperature.toString())
        views.setTextViewText(R.id.condition_text, weatherData.condition)

        // 現在時刻を設定
        val currentTime = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault())
            .format(java.util.Date())
        views.setTextViewText(R.id.time_text, currentTime)

        // 天気に応じて背景を動的に変更
        updateBackgroundForWeather(views, weatherData.condition)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun updateBackgroundForWeather(views: RemoteViews, condition: String) {
        // 天気に応じて背景リソースを選択（改善版）
        val backgroundRes = when (condition) {
            "Sunny" -> R.drawable.sunny_background_improved
            "Rainy", "Thunderstorm" -> R.drawable.rainy_background_improved
            "Cloudy", "Partly Cloudy" -> R.drawable.neumorphism_background
            "Snowy" -> R.drawable.neumorphism_background
            else -> R.drawable.sunny_background_improved
        }

        // ウィジェット全体の背景を設定
        views.setInt(R.id.widget_container, "setBackgroundResource", backgroundRes)
    }
}