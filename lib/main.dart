import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battery Info',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('fast.smd.dev/battery');
  String _batteryLevel = 'Unknown battery level.';
  String _chargingStatus = 'Unknown charging status.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Info'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _getBatteryInfo,
              child: const Text('Get Battery Info'),
              // color of the button
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 2, 90, 4),
                // color of the text
                foregroundColor: const Color.fromARGB(255, 251, 250, 250),
                // color of the border
                side: const BorderSide(
                  color: Color.fromARGB(255, 251, 250, 250),
                  width: 2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
            Column(
              children: [
                Text(
                  _batteryLevel,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  _chargingStatus,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            Icon(
              _chargingStatus.contains('Charging')
                  ? Icons.battery_charging_full
                  : Icons.battery_full,
              size: 100,
              color: _chargingStatus.contains('Charging')
                  ? Colors.green
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getBatteryInfo() async {
    String batteryLevel;
    String chargingStatus;
    try {
      final batteryResult = await platform.invokeMethod<int>('getBatteryLevel');
      batteryLevel = 'Battery level : $batteryResult%.';

      final chargingResult =
          await platform.invokeMethod<String>('getChargingStatus');
      chargingStatus = 'Charging status: $chargingResult.';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
      chargingStatus = "Failed to get charging status: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
      _chargingStatus = chargingStatus;
    });
  }
}