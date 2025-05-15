import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoricalChartPage extends StatefulWidget {
  const HistoricalChartPage({super.key});

  @override
  _HistoricalChartPageState createState() => _HistoricalChartPageState();
}

class _HistoricalChartPageState extends State<HistoricalChartPage> {
  String selectedTab = "Daily";
  String selectedPollutant = "AQI";
  DateTime selectedDate = DateTime.now();

  final Map<String, List<double>> pollutantData = {
    "AQI": [33, 58, 39, 70, 53],
    "PM 2.5": [20, 40, 60, 80, 100],
    "PM 10": [15, 30, 45, 60, 75],
    "NO2": [25, 35, 55, 65, 85],
    "CO": [12, 24, 36, 48, 60],
    "SO2": [10, 20, 30, 40, 50],
  };

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Historical Data', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Selection
          Container(
            color: Colors.blue[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [""].map((tab) {
                return TextButton(
                  onPressed: () => setState(() => selectedTab = tab),
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: selectedTab == tab ? Colors.blueAccent : Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Pollutant Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: pollutantData.keys.map((pollutant) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPollutant == pollutant
                          ? Colors.blueAccent
                          : Colors.white,
                      side: BorderSide(color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => setState(() => selectedPollutant = pollutant),
                    child: Text(
                      pollutant,
                      style: TextStyle(
                        color: selectedPollutant == pollutant
                            ? Colors.white
                            : Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Display Charts
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Line Chart
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$selectedTab $selectedPollutant Range",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              height: 200,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: true),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index >= 0 &&
                                              index <
                                                  pollutantData[selectedPollutant]!
                                                      .length) {
                                            return Text(
                                              ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'][index],
                                              style: TextStyle(fontSize: 12),
                                            );
                                          }
                                          return Text('');
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: true),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(
                                        pollutantData[selectedPollutant]!.length,
                                        (index) => FlSpot(
                                            index.toDouble(),
                                            pollutantData[selectedPollutant]![index]),
                                      ),
                                      isCurved: true,
                                      color: Colors.blue,
                                      barWidth: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bar Chart
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$selectedTab $selectedPollutant Increased",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          return Text(
                                            ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'][index],
                                            style: TextStyle(fontSize: 12),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: true),
                                  barGroups: List.generate(
                                    pollutantData[selectedPollutant]!.length,
                                    (index) => BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          fromY: 0,
                                          toY: pollutantData[selectedPollutant]![index],
                                          color: Colors.green,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
