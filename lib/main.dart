import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String appGroupId = 'group.homeWidgetSandbox';
  String iosWidgetName = 'HomeWidget';
  String androidWidgetName = 'HomeWidget';
  String dataKey = 'text_from_app';

  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId(appGroupId);
  }

  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
    });

    // save
    String data = 'Count : $_counter';
    await HomeWidget.saveWidgetData<String>(dataKey, data);

    // update
    await HomeWidget.updateWidget(
      iOSName: iosWidgetName,
      androidName: androidWidgetName,
    );
  }

  Future<void> _fetchWeatherData() async {
    // ランダムな天気データを生成
    final random = Random();
    final temperatures = [15, 18, 22, 25, 28, 30, 32];
    final conditions = ['Sunny', 'Cloudy', 'Rainy', 'Snowy'];

    final temp = temperatures[random.nextInt(temperatures.length)];
    final condition = conditions[random.nextInt(conditions.length)];

    String weatherData = '$condition $temp°C';

    // save weather data
    await HomeWidget.saveWidgetData<String>(dataKey, weatherData);

    // update widget
    await HomeWidget.updateWidget(
      iOSName: iosWidgetName,
      androidName: androidWidgetName,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchWeatherData,
              child: const Text('Update Weather Widget'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
