import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/map_action.dart';
import '../../models/trip_model.dart';
import '../../providers/map_provider.dart';
import '../../services/database_service.dart';

class TripStarted extends StatelessWidget {
  const TripStarted({Key? key}) : super(key: key);

  void _reachedDestination(Trip ongoingTrip, MapProvider mapProvider) {
    final DatabaseService dbService = DatabaseService();
    ongoingTrip.reachedDestination = true;
    dbService.updateTrip(ongoingTrip);
    mapProvider.reachedDestination(ongoingTrip);
  }

  @override
  Widget build(BuildContext context) {
    final MapProvider mapProvider = Provider.of<MapProvider>(
      context,
      listen: false,
    );
    Trip? ongoingTrip = mapProvider.ongoingTrip ?? Trip();

    return Visibility(
      visible: mapProvider.mapAction == MapAction.tripStarted,
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
                  'Trip Started',
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
                        if (ongoingTrip.destinationAddress != null)
                          Column(
                            children: [
                              _buildInfoText(
                                'Heading Towards: ',
                                ongoingTrip.destinationAddress!,
                              ),
                              const SizedBox(height: 2),
                            ],
                          ),
                        if (mapProvider.distanceBetweenRoutes != null)
                          _buildInfoText(
                            'Remaining Distance: ',
                            '${mapProvider.distanceBetweenRoutes!.toStringAsFixed(2)} Km',
                          )
                        else
                          _buildInfoText(
                            'Remaining Distance: ',
                            '--',
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
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () => _reachedDestination(ongoingTrip, mapProvider),
                child: const Text('REACHED DESTINATION'),
              ),
            ],
          ),
        ),
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
