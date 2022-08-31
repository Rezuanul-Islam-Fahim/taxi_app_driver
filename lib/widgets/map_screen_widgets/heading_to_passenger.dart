import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/map_action.dart';
import '../../models/trip_model.dart';
import '../../providers/map_provider.dart';
import '../../services/database_service.dart';

class HeadingToPassenger extends StatelessWidget {
  const HeadingToPassenger({Key? key}) : super(key: key);

  void _arrivedToPassenger(Trip ongoingTrip, MapProvider mapProvider) {
    final DatabaseService dbService = DatabaseService();
    ongoingTrip.arrived = true;
    dbService.updateTrip(ongoingTrip);
    mapProvider.arrivedToPassenger(ongoingTrip);
  }

  @override
  Widget build(BuildContext context) {
    final MapProvider mapProvider = Provider.of<MapProvider>(
      context,
      listen: false,
    );
    Trip? ongoingTrip = mapProvider.ongoingTrip ?? Trip();

    return Visibility(
      visible: mapProvider.mapAction == MapAction.tripAccepted,
      child: Positioned(
        bottom: 15,
        left: 15,
        right: 15,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Center(
                child: Text(
                  'Heading To Passenger',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ongoingTrip.pickupAddress != null)
                          Text(
                            ongoingTrip.pickupAddress!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (mapProvider.distanceBetweenRoutes == null)
                          const Text('Distance: --')
                        else
                          Text(
                            'Distance ${mapProvider.distanceBetweenRoutes!.toStringAsFixed(2)} Km',
                          ),
                      ],
                    ),
                  ),
                  if (ongoingTrip.cost != null)
                    Chip(
                      label: Text('\$${ongoingTrip.cost!.toStringAsFixed(2)}'),
                      backgroundColor: Colors.black,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _arrivedToPassenger(
                  ongoingTrip,
                  mapProvider,
                ),
                child: const Text('ARRIVED'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
