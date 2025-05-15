import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart'; // Import for the gauge chart

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String apiKey = 'e35fba1dbb56b743e3684a6a21891bb0';
  double lat = 0.0;
  double lon = 0.0;

  String temperature = 'Loading...';
  String humidity = 'Loading...';
  String windSpeed = 'Loading...';
  String aqi = 'Loading...';
  String airQualityStatus = 'Loading...';
  String airQualityMessage = 'Loading...';
  String precautions = 'Loading...'; // Precautions based on AQI
  Color airQualityColor = Colors.grey;

  // Pollutants
  String pm25 = 'Loading...';
  String pm10 = 'Loading...';
  String co = 'Loading...';

  bool isLoading = true;
  int aqiValue = 100; // Default AQI value for the gauge chart

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => isLoading = true);

    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showError('Location permission denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        lat = position.latitude;
        lon = position.longitude;
      });

      await fetchWeatherData();
      await fetchAirPollutionData();
    } catch (e) {
      _showError('Failed to fetch location');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchWeatherData() async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          temperature = '${data['main']['temp']}°C';
          humidity = '${data['main']['humidity']}%';
          windSpeed = '${data['wind']['speed']} km/h';
        });
      } else {
        _showError('Failed to fetch weather data');
      }
    } catch (e) {
      _showError('Weather data error: $e');
    }
  }

  Future<void> fetchAirPollutionData() async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        int fetchedAqiValue = data['list'][0]['main']['aqi'];

        // Fetch pollutant values
        pm25 = '${data['list'][0]['components']['pm2_5']} µg/m³';
        pm10 = '${data['list'][0]['components']['pm10']} µg/m³';
        co = '${data['list'][0]['components']['co']} µg/m³';

        setState(() {
          aqiValue = fetchedAqiValue * 100; // Scale AQI to 100-500 range
          aqi = '$aqiValue';
          airQualityStatus = getAirQualityStatus(aqiValue);
          airQualityMessage = getAirQualityMessage(aqiValue);
          precautions = getPrecautions(aqiValue); // Get precautions
          airQualityColor = getDynamicColor(aqiValue);
        });
      } else {
        _showError('Failed to fetch air pollution data');
      }
    } catch (e) {
      _showError('Air pollution data error: $e');
    }
  }

  String getAirQualityStatus(int aqiValue) {
    if (aqiValue <= 150) return 'Moderate';
    if (aqiValue <= 200) return 'Unhealthy';
    if (aqiValue <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  String getAirQualityMessage(int aqiValue) {
    if (aqiValue <= 150) return 'Air quality is acceptable.';
    if (aqiValue <= 200) return 'High health risk for sensitive groups.';
    if (aqiValue <= 300) return 'Health warnings for everyone.';
    return 'Serious health effects.';
  }

  String getPrecautions(int aqiValue) {
    if (aqiValue <= 150) {
      return '• Sensitive groups should reduce outdoor activities.\n'
          '• Keep windows closed to avoid outdoor air.';
    } else if (aqiValue <= 200) {
      return '• Avoid prolonged outdoor activities.\n'
          '• Wear a mask if going outside.\n'
          '• Use air purifiers indoors.';
    } else if (aqiValue <= 300) {
      return '• Everyone should avoid outdoor activities.\n'
          '• Wear an N95 mask if necessary to go outside.\n'
          '• Keep indoor air clean with air purifiers.';
    } else {
      return '• Stay indoors and avoid all outdoor activities.\n'
          '• Use air purifiers and keep windows closed.\n'
          '• Seek medical attention if you experience health issues.';
    }
  }

  Color getDynamicColor(int aqiValue) {
    if (aqiValue <= 150) return Colors.yellow;
    if (aqiValue <= 200) return Colors.orange;
    if (aqiValue <= 300) return Colors.red;
    return Colors.purple;
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _refreshData() async {
    await _getLocation();
  }

  Widget InfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        subtitle: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGaugeChart() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 100,
            maximum: 500,
            ranges: <GaugeRange>[
              GaugeRange(startValue: 100, endValue: 150, color: Colors.yellow, label: 'Moderate'),
              GaugeRange(startValue: 151, endValue: 200, color: Colors.orange, label: 'Unhealthy'),
              GaugeRange(startValue: 201, endValue: 300, color: Colors.red, label: 'Very Unhealthy'),
              GaugeRange(startValue: 301, endValue: 500, color: Colors.purple, label: 'Hazardous'),
            ],
            pointers: <GaugePointer>[
              NeedlePointer(
                value: aqiValue.toDouble(),
                needleColor: Colors.black,
                knobStyle: KnobStyle(color: Colors.black),
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(
                  'AQI: $aqiValue',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                angle: 90,
                positionFactor: 0.5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 30),
            const SizedBox(width: 8),
            const Text('VayuVeda', style: TextStyle(color: Colors.teal, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildGaugeChart(), // Add the gauge chart at the top
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: airQualityColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Air Quality Status', style: TextStyle(fontSize: 20)),
                        Text(airQualityStatus, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        Text('AQI: $aqi', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(airQualityMessage),
                      ],
                    ),
                  ),
                  InfoCard(icon: Icons.thermostat, title: 'Temperature', value: temperature),
                  InfoCard(icon: Icons.water_drop, title: 'Humidity', value: humidity),
                  InfoCard(icon: Icons.air, title: 'Wind Speed', value: windSpeed),
                  const SizedBox(height: 16),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Precautions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(precautions, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}