import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';

import '../models/map_action.dart';
import '../providers/map_provider.dart';
import '../widgets/map_screen_widgets/bottom_draggable_sheet.dart';
import '../widgets/map_screen_widgets/heading_to_passenger.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  static const String route = '/home';

  @override
  Widget build(BuildContext context) {
    Provider.of<MapProvider>(context, listen: false).initializeMap();

    return Scaffold(
      body: Consumer<MapProvider>(
        builder: (BuildContext context, MapProvider mapProvider, _) {
          return SafeArea(
            child: Stack(
              children: [
                mapProvider.cameraPos != null
                    ? GoogleMap(
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        onMapCreated: mapProvider.onMapCreated,
                        initialCameraPosition: mapProvider.cameraPos!,
                        compassEnabled: true,
                        onCameraMove: mapProvider.onCameraMove,
                        markers: mapProvider.markers!,
                        polylines: mapProvider.polylines!,
                        padding: const EdgeInsets.only(bottom: 90),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
                mapProvider.mapAction == MapAction.browse
                    ? const BottomDraggableSheet()
                    : Container(),
                HeadingToPassenger(key: key),
              ],
            ),
          );
        },
      ),
    );
  }
}