import 'package:flutter/material.dart';

class CompletedTripsScreen extends StatelessWidget {
  const CompletedTripsScreen({Key? key}) : super(key: key);

  static const String route = '/completed-trips';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Trips'),
        backgroundColor: Colors.black,
      ),
    );
  }
}
