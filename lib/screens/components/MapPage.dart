import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class MapPage extends StatefulWidget {
  const MapPage({super.key, this.markerColor, this.aqiLevel});

  final Color? markerColor;
  final int? aqiLevel;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final String apiKey = '5fde2c6930838e0d59f8cdf96812b143';
  LatLng currentLocation = LatLng(50.0, 50.0); // Default location
  List<Marker> markers = [];
  String aqi = 'Loading...';
  String city = 'Loading...';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
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
        currentLocation = LatLng(position.latitude, position.longitude);
      });

      await _fetchAQIData(currentLocation.latitude, currentLocation.longitude);
    } catch (e) {
      _showError('Failed to fetch location');
    }
  }

  Future<void> _fetchAQIData(double lat, double lon) async {
    final url = Uri.parse(
        'http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract AQI and city information
        int fetchedAqiValue = data['list'][0]['main']['aqi'];
        String fetchedCity = 'Station at ($lat, $lon)'; // Placeholder for station info

        setState(() {
          aqi = fetchedAqiValue.toString();
          city = fetchedCity;

          // Update markers
          markers = [
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(lat, lon),
              builder: (ctx) => Container(
                child: Column(
                  children: [
                    Icon(Icons.location_on, color: _getMarkerColor(fetchedAqiValue), size: 40.0),
                    Text('AQI: $aqi', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ];
        });
      } else {
        _showError('Failed to fetch AQI data');
      }
    } catch (e) {
      _showError('Error fetching AQI data: $e');
    }
  }

  Color _getMarkerColor(int aqiValue) {
    switch (aqiValue) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      case 5:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AQI Map'),
        backgroundColor: Colors.teal,
      ),
      body: FlutterMap(
        options: MapOptions(
          center: currentLocation,
          zoom: 5.0,
          onTap: (_, LatLng latLng) async {
            setState(() {
              currentLocation = latLng;
            });
            await _fetchAQIData(latLng.latitude, latLng.longitude);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: markers,
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('City: $city', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('AQI Level: $aqi', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}