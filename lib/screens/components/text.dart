import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  String selectedRange = 'daily';
  List<double> historicalData = [];
  final String apiKey = "apikey";
  final double lat = 37.7749;
  final double lon = -122.4194;
  bool isLoading = true;
  double currentAQI = 0;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchHistoricalData();
  }

  int getUnixTimestamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  Future<void> fetchHistoricalData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    int end = getUnixTimestamp(DateTime.now());
    int start = getUnixTimestamp(
      DateTime.now().subtract(const Duration(days: 7)),
    );

    String apiUrl =
        'https://history.openweathermap.org/data/2.5/air_pollution/history?lat=$lat&lon=$lon&start=$start&end=$end&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      debugPrint("API Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['list'] == null || (data['list'] as List).isEmpty) {
          setState(() {
            errorMessage = "No historical data found!";
            historicalData = [];
            currentAQI = 0;
          });
        } else {
          setState(() {
            historicalData = (data['list'] as List)
                .map((item) => (item['components']['pm2_5'] as num).toDouble())
                .toList();
            currentAQI = (data['list'].last['main']['aqi'] as num).toDouble();
          });
        }
      } else {
        setState(() {
          errorMessage = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Air Pollution Data")),
      body: Column(
        children: [
          // Range Selection Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFilterButton("daily"),
              _buildFilterButton("weekly"),
              _buildFilterButton("monthly"),
            ],
          ),
          const SizedBox(height: 20),

          // Speedometer Gauge
          _buildSpeedometerGauge(currentAQI),
          const SizedBox(height: 20),

          // Line Chart
          Expanded(child: _buildLineChart()),

          const SizedBox(height: 20),

          // Bar Chart
          Expanded(child: _buildBarChart()),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String range) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedRange = range;
        });
        fetchHistoricalData();
      },
      child: Text(range.toUpperCase()),
    );
  }

  Widget _buildLineChart() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (historicalData.isEmpty) {
      return const Center(child: Text("No Data Available"));
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: historicalData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value);
              }).toList(),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
              ),
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (historicalData.isEmpty) {
      return const Center(child: Text("No Data Available"));
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: false),
          barGroups: historicalData.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  gradient: const LinearGradient(
                    colors: [Colors.teal, Colors.green],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSpeedometerGauge(double aqiValue) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 500,
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: 0,
                endValue: 50,
                color: Colors.green,
                label: 'Good',
              ),
              GaugeRange(
                startValue: 51,
                endValue: 100,
                color: Colors.yellow,
                label: 'Moderate',
              ),
              GaugeRange(
                startValue: 101,
                endValue: 150,
                color: Colors.orange,
                label: 'Unhealthy',
              ),
              GaugeRange(
                startValue: 151,
                endValue: 200,
                color: Colors.red,
                label: 'Very Unhealthy',
              ),
              GaugeRange(
                startValue: 201,
                endValue: 300,
                color: Colors.purple,
                label: 'Hazardous',
              ),
              GaugeRange(
                startValue: 301,
                endValue: 500,
                color: Colors.brown,
                label: 'Severe',
              ),
            ],
            pointers: <GaugePointer>[
              NeedlePointer(
                value: aqiValue,
                needleColor: Colors.black,
                knobStyle: KnobStyle(color: Colors.black),
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(
                  "AQI: ${aqiValue.toStringAsFixed(1)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
}
