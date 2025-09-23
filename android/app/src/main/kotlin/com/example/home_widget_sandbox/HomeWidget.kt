package com.example.home_widget_sandbox

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.SharedPreferences
import kotlin.random.Random

class HomeWidget : AppWidgetProvider() {

    private fun generateWeatherData(context: Context): String {
        // API呼び出しのシミュレーション
        val temperatures = arrayOf(15, 18, 22, 25, 28, 30, 32)
        val conditions = arrayOf("Sunny", "Cloudy", "Rainy", "Snowy")

        val temp = temperatures.random()
        val condition = conditions.random()

        val weatherText = "$condition ${temp}°C"

        // SharedPreferencesに保存
        val sharedPref = context.getSharedPreferences("group.homeWidgetSandbox", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putString("text_from_app", weatherText)
            apply()
        }

        return weatherText
    }

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
        val weatherText = generateWeatherData(context)

        // ウィジェットのビューを更新
        val views = RemoteViews(context.packageName, R.layout.home_widget)
        views.setTextViewText(R.id.weather_text, weatherText)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}