import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/map_action.dart';
import '../../models/trip_model.dart';
import '../../providers/map_provider.dart';
import '../../services/database_service.dart';

class CollectCash extends StatelessWidget {
  const CollectCash({Key? key}) : super(key: key);

  void _collectCash(
    BuildContext context,
    Trip ongoingTrip,
    MapProvider mapProvider,
  ) {
    final DatabaseService dbService = DatabaseService();
    ongoingTrip.tripCompleted = true;
    dbService.updateTrip(ongoingTrip);
    mapProvider.completeTrip();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip Completed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MapProvider mapProvider = Provider.of<MapProvider>(
      context,
      listen: false,
    );
    Trip? ongoingTrip = mapProvider.ongoingTrip ?? Trip();

    return Visibility(
      visible: mapProvider.mapAction == MapAction.reachedDestination,
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
                  'Reached Destination',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              if (ongoingTrip.cost != null)
                Center(
                  child: Text(
                    '\$${ongoingTrip.cost!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onPressed: () => _collectCash(
                  context,
                  ongoingTrip,
                  mapProvider,
                ),
                label: const Text('COLLECT CASH'),
                icon: const Icon(Icons.attach_money_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
