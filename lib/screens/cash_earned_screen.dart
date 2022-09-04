import 'package:flutter/material.dart';

import '../models/trip_model.dart';
import '../services/database_service.dart';
import '../widgets/side_drawer.dart';

class CashEarnedScreen extends StatelessWidget {
  const CashEarnedScreen({Key? key}) : super(key: key);

  static const String route = '/cash-earned';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Earned'),
        backgroundColor: Colors.black,
      ),
      drawer: const CustomSideDrawer(),
      body: FutureBuilder(
        future: DatabaseService().getDriverCompletedTrips(),
        builder: (BuildContext context, AsyncSnapshot<List<Trip>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Trip> trips = snapshot.data as List<Trip>;
          double totalEarned = trips.fold<double>(
            0,
            (previousValue, element) => previousValue + element.cost!,
          );

          return trips.isNotEmpty
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Total Cash Earned',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Chip(
                      label: Text(
                        '\$${totalEarned.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ))
              : const Center(
                  child: Text('No Completed Trip Found'),
                );
        },
      ),
    );
  }
}
