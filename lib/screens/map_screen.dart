import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';

import '../models/map_action.dart';
import '../providers/map_provider.dart';
import '../widgets/map_screen_widgets/bottom_draggable_sheet.dart';
import '../widgets/map_screen_widgets/collect_cash.dart';
import '../widgets/map_screen_widgets/floating_drawer_bar_button.dart';
import '../widgets/map_screen_widgets/heading_to_passenger.dart';
import '../widgets/map_screen_widgets/start_trip.dart';
import '../widgets/map_screen_widgets/trip_started.dart';
import '../widgets/side_drawer.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  static const String route = '/home';

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    Provider.of<MapProvider>(context, listen: false).initializeMap(
      scaffoldKey: scaffoldKey,
    );

    return Consumer<MapProvider>(
      builder: (BuildContext context, MapProvider mapProvider, _) {
        return Scaffold(
          key: scaffoldKey,
          drawer: const CustomSideDrawer(),
          body: SafeArea(
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
                        padding: const EdgeInsets.only(bottom: 120),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
                mapProvider.mapAction == MapAction.browse
                    ? const BottomDraggableSheet()
                    : Container(),
                HeadingToPassenger(key: key),
                StartTrip(key: key),
                TripStarted(key: key),
                CollectCash(key: key),
                FloatingDrawerBarButton(scaffoldKey: scaffoldKey),
              ],
            ),
          ),
        );
      },
    );
  }
}
