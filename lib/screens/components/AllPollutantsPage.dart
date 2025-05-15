import 'package:flutter/material.dart';

class AllPollutantsPage extends StatelessWidget {
  final Map<String, dynamic> pollutants;

  const AllPollutantsPage({
    super.key, required this.pollutants
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Air Pollutants'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: pollutants.length,
          itemBuilder: (context, index) {
            String key = pollutants.keys.elementAt(index);
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(key),
                subtitle: Text('${pollutants[key]} µg/m³'),
              ),
            );
          },
        ),
      ),
    );
  }
}