import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../constant.dart';
import '../models/map_action.dart';
import '../models/trip_model.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class MapProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  late GlobalKey<ScaffoldState>? _scaffoldKey;
  late CameraPosition? _cameraPos;
  late GoogleMapController? _controller;
  late Position? _deviceLocation;
  late String? _deviceAddress;
  late BitmapDescriptor? _selectionPin;
  late BitmapDescriptor? _personPin;
  late Set<Marker>? _markers;
  late Set<Polyline>? _polylines;
  late MapAction? _mapAction;
  late Trip? _ongoingTrip;
  late double? _distanceBetweenRoutes;
  late StreamSubscription<Position>? _positionStream;

  GlobalKey<ScaffoldState>? get scaffoldKey => _scaffoldKey;
  CameraPosition? get cameraPos => _cameraPos;
  GoogleMapController? get controller => _controller;
  Position? get deviceLocation => _deviceLocation;
  String? get deviceAddress => _deviceAddress;
  Set<Marker>? get markers => _markers;
  Set<Polyline>? get polylines => _polylines;
  MapAction? get mapAction => _mapAction;
  Trip? get ongoingTrip => _ongoingTrip;
  double? get distanceBetweenRoutes => _distanceBetweenRoutes;
  StreamSubscription<Position>? get positionStream => _positionStream;

  MapProvider() {
    _scaffoldKey = null;
    _mapAction = MapAction.browse;
    _cameraPos = null;
    _deviceLocation = null;
    _deviceAddress = null;
    _markers = {};
    _polylines = {};
    _ongoingTrip = null;
    _distanceBetweenRoutes = null;
    _positionStream = null;
    setCustomPin();

    if (kDebugMode) {
      print('=====///=============///=====');
      print('Map provider loaded');
      print('///==========///==========///');
    }
  }

  void setScaffoldKey(GlobalKey<ScaffoldState> scaffoldKey) {
    _scaffoldKey = scaffoldKey;
  }

  Future<void> setCustomPin() async {
    _selectionPin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.5, size: Size(10, 10)),
      'images/pin.png',
    );
    _personPin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.5, size: Size(10, 10)),
      'images/map-person.png',
    );
  }

  Future<void> initializeMap({GlobalKey<ScaffoldState>? scaffoldKey}) async {
    Position? deviceLocation;
    LatLng? cameraLatLng;

    setScaffoldKey(scaffoldKey!);

    if (await _locationService.checkLocationIfPermanentlyDisabled()) {
      showDialog(
        context: _scaffoldKey!.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text(
              'Location permission is permanently disabled. Enable it from app settings',
            ),
            actions: [
              TextButton(
                onPressed: () => Geolocator.openAppSettings(),
                child: const Text('Open App Settings'),
              ),
            ],
          );
        },
      );
    } else {
      if (await _locationService.checkLocationPermission()) {
        try {
          deviceLocation = await _locationService.getLocation();
          cameraLatLng = LatLng(
            deviceLocation.latitude,
            deviceLocation.longitude,
          );
          setDeviceLocation(deviceLocation);
          setDeviceLocationAddress(
            deviceLocation.latitude,
            deviceLocation.longitude,
          );
        } catch (error) {
          if (kDebugMode) {
            print('=====///=============///=====');
            print('Unable to get device location');
            print('///==========///==========///');
          }
        }
      }
    }

    if (deviceLocation == null) {
      cameraLatLng = const LatLng(37.42227936982647, -122.08611108362673);
    }

    setCameraPosition(cameraLatLng!);

    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void onCameraMove(CameraPosition pos) {
    if (kDebugMode) {
      print(pos.target.latitude);
      print(pos.target.longitude);
    }
  }

  void setCameraPosition(LatLng latLng, {double zoom = 15}) {
    _cameraPos = CameraPosition(
      target: LatLng(latLng.latitude, latLng.longitude),
      zoom: zoom,
    );
  }

  void setDeviceLocation(Position location) {
    _deviceLocation = location;
  }

  void listenToPositionStream() {
    _positionStream = LocationService().getRealtimeDeviceLocation().listen(
      (Position pos) {
        if (kDebugMode) {
          print(pos.toString());
        }

        updateUserLocation(pos);
        setDeviceLocation(pos);
        setDeviceLocationAddress(
          pos.latitude,
          pos.longitude,
        );

        if (mapAction == MapAction.tripAccepted) {
          updateRoutes(
            LatLng(pos.latitude, pos.longitude),
            LatLng(
              _ongoingTrip!.pickupLatitude!,
              ongoingTrip!.pickupLongitude!,
            ),
          );
        } else if (mapAction == MapAction.tripStarted) {
          updateRoutes(
            LatLng(pos.latitude, pos.longitude),
            LatLng(
              _ongoingTrip!.destinationLatitude!,
              ongoingTrip!.destinationLongitude!,
            ),
          );
        }
      },
    );
  }

  void setDeviceLocationAddress(double latitude, double longitude) {
    placemarkFromCoordinates(latitude, longitude)
        .then((List<Placemark> places) {
      _deviceAddress = places[2].name;

      if (kDebugMode) {
        print(places[2].toString());
      }
    });
  }

  void updateUserLocation(Position pos) {
    DatabaseService().updateUser({
      'heading': pos.heading,
      'userLatitude': pos.latitude,
      'userLongitude': pos.longitude,
    });
  }

  Future<void> updateRoutes(LatLng firstPoint, LatLng lastPoint) async {
    PolylineResult result = await setPolyline(
      firstPoint: firstPoint,
      lastPoint: lastPoint,
    );

    if (_markers!.isNotEmpty) {
      calculateDistanceBetweenRoutes(result.points);
      notifyListeners();
    }
  }

  void addMarker(LatLng pos, BitmapDescriptor pin) {
    _markers!.add(
      Marker(
        markerId: MarkerId(const Uuid().v4()),
        icon: pin,
        position: pos,
      ),
    );
  }

  Future<PolylineResult> setPolyline({
    LatLng? firstPoint,
    LatLng? lastPoint,
  }) async {
    _polylines!.clear();

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      googleMapApi,
      PointLatLng(firstPoint!.latitude, firstPoint.longitude),
      PointLatLng(lastPoint!.latitude, lastPoint.longitude),
    );

    if (kDebugMode) {
      print(result.points);
    }

    if (result.points.isNotEmpty) {
      final String polylineId = const Uuid().v4();

      _polylines!.add(
        Polyline(
          polylineId: PolylineId(polylineId),
          color: Colors.black87,
          points: result.points
              .map((PointLatLng point) =>
                  LatLng(point.latitude, point.longitude))
              .toList(),
          width: 4,
        ),
      );
    }

    return result;
  }

  void clearPaths() {
    _markers!.clear();
    _polylines!.clear();
  }

  void changeMapAction(MapAction mapAction) {
    _mapAction = mapAction;
  }

  void resetMapAction() {
    _mapAction = MapAction.browse;
  }

  LatLng getNorthEastLatLng(LatLng firstPoint, LatLng lastPoint) => LatLng(
        firstPoint.latitude >= lastPoint.latitude
            ? firstPoint.latitude
            : lastPoint.latitude,
        firstPoint.longitude >= lastPoint.longitude
            ? firstPoint.longitude
            : lastPoint.longitude,
      );

  LatLng getSouthWestLatLng(LatLng firstPoint, LatLng lastPoint) => LatLng(
        firstPoint.latitude <= lastPoint.latitude
            ? firstPoint.latitude
            : lastPoint.latitude,
        firstPoint.longitude <= lastPoint.longitude
            ? firstPoint.longitude
            : lastPoint.longitude,
      );

  Future<void> showTrip(LatLng pickup, LatLng destination) async {
    _markers!.clear();

    addMarker(pickup, _personPin!);
    addMarker(destination, _selectionPin!);
    await setPolyline(firstPoint: pickup, lastPoint: destination);

    notifyListeners();
    _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: getNorthEastLatLng(pickup, destination),
          southwest: getSouthWestLatLng(pickup, destination),
        ),
        160,
      ),
    );
  }

  void updateOngoingTrip(Trip trip) {
    _ongoingTrip = trip;
  }

  void calculateDistanceBetweenRoutes(List<PointLatLng> points) {
    double distance = 0;

    for (int i = 0; i < points.length - 1; i++) {
      distance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }

    _distanceBetweenRoutes = distance / 1000;
  }

  Future<void> acceptTrip(Trip trip) async {
    changeMapAction(MapAction.tripAccepted);
    clearPaths();
    updateOngoingTrip(trip);
    addMarker(
      LatLng(trip.pickupLatitude!, trip.pickupLongitude!),
      _personPin!,
    );
    PolylineResult polylines = await setPolyline(
      firstPoint: LatLng(trip.pickupLatitude!, trip.pickupLongitude!),
      lastPoint: LatLng(_deviceLocation!.latitude, _deviceLocation!.longitude),
    );
    calculateDistanceBetweenRoutes(polylines.points);
    listenToPositionStream();
    _controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _deviceLocation!.latitude,
            _deviceLocation!.longitude,
          ),
          bearing: _deviceLocation!.heading,
          tilt: 30,
          zoom: 17,
        ),
      ),
    );

    notifyListeners();
  }

  Future<void> arrivedToPassenger(Trip trip) async {
    changeMapAction(MapAction.arrived);
    updateOngoingTrip(trip);
    clearPaths();
    addMarker(
      LatLng(trip.destinationLatitude!, trip.destinationLongitude!),
      _selectionPin!,
    );
    PolylineResult result = await setPolyline(
      firstPoint: LatLng(
        trip.destinationLatitude!,
        trip.destinationLongitude!,
      ),
      lastPoint: LatLng(
        _deviceLocation!.latitude,
        _deviceLocation!.longitude,
      ),
    );
    calculateDistanceBetweenRoutes(result.points);
    _positionStream!.cancel();
    _positionStream = null;

    _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: getNorthEastLatLng(
            LatLng(trip.destinationLatitude!, trip.destinationLongitude!),
            LatLng(
              _deviceLocation!.latitude,
              _deviceLocation!.longitude,
            ),
          ),
          southwest: getSouthWestLatLng(
            LatLng(trip.destinationLatitude!, trip.destinationLongitude!),
            LatLng(
              _deviceLocation!.latitude,
              _deviceLocation!.longitude,
            ),
          ),
        ),
        160,
      ),
    );

    notifyListeners();
  }

  Future<void> startTrip(Trip trip) async {
    updateOngoingTrip(trip);
    changeMapAction(MapAction.tripStarted);

    _controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _deviceLocation!.latitude,
            _deviceLocation!.longitude,
          ),
          bearing: _deviceLocation!.heading,
          tilt: 30,
          zoom: 17,
        ),
      ),
    );

    notifyListeners();
  }

  void reachedDestination(Trip trip) {
    updateOngoingTrip(trip);
    changeMapAction(MapAction.reachedDestination);
    clearPaths();
    _distanceBetweenRoutes = null;

    notifyListeners();

    animateCameraToPos(
      LatLng(_deviceLocation!.latitude, _deviceLocation!.longitude),
      16,
    );
  }

  void completeTrip() {
    resetMapAction();
    _ongoingTrip = null;

    notifyListeners();
  }

  void animateCameraToPos(LatLng pos, [double zoom = 15]) {
    _controller!.animateCamera(CameraUpdate.newLatLngZoom(pos, zoom));
  }
}
