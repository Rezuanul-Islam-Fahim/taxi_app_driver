import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/trip_model.dart';
import '../../providers/map_provider.dart';
import '../../services/database_service.dart';

class BottomDraggableSheet extends StatefulWidget {
  const BottomDraggableSheet({Key? key}) : super(key: key);

  @override
  State<BottomDraggableSheet> createState() => _BottomDraggableSheetState();
}

class _BottomDraggableSheetState extends State<BottomDraggableSheet> {
  final DatabaseService _dbService = DatabaseService();
  late MapProvider _mapProvider;
  List<Trip> _trips = [];

  void getAllTrips() {
    _dbService.getTrips().listen((List<Trip> trips) {
      if (mounted) {
        setState(() {
          _trips = trips;
        });
      }
    });
  }

  void _acceptTrip(Trip trip) async {
    trip.accepted = true;
    trip.driverId = FirebaseAuth.instance.currentUser!.uid;
    await _dbService.updateTrip(trip);
    _mapProvider.acceptTrip(trip);
  }

  @override
  void initState() {
    _mapProvider = Provider.of<MapProvider>(
      context,
      listen: false,
    );
    getAllTrips();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.1,
      maxChildSize: 1,
      builder: (BuildContext context, ScrollController controller) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey[200]!,
                offset: const Offset(0, -2),
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.white,
          ),
          child: ListView.builder(
            controller: controller,
            itemCount: _trips.isNotEmpty ? _trips.length + 1 : 2,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300]!,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                  ),
                );
              } else if (index == 1 && _trips.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Center(
                    child: Text(
                      'No Ongoing Trip Found',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }

              Trip trip = _trips[index - 1];
              return _buildTripPanel(trip);
            },
          ),
        );
      },
    );
  }

  Widget _buildTripPanel(Trip trip) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoText('From: ', trip.pickupAddress!),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoText('To: ', trip.destinationAddress!),
                    const SizedBox(height: 2),
                    _buildInfoText(
                      'Distance: ',
                      '${trip.distance!.toStringAsFixed(2)} Km',
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  'Cost: \$${trip.cost!.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black,
                labelStyle: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => _acceptTrip(trip),
                child: const Text('Start Trip'),
              ),
              ElevatedButton(
                onPressed: () => _mapProvider.showTrip(
                  LatLng(trip.pickupLatitude!, trip.pickupLongitude!),
                  LatLng(trip.destinationLatitude!, trip.destinationLongitude!),
                ),
                child: const Text('Show on Map'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String title, String info) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: info,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
