import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../services/location_service.dart';

class MapProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  late CameraPosition? _cameraPos;
  late GoogleMapController? _controller;
  late Position? _deviceLocation;
  late String? _deviceAddress;
  late BitmapDescriptor? _selectionPin;
  late BitmapDescriptor? _personPin;
  late Set<Marker>? _markers;

  CameraPosition? get cameraPos => _cameraPos;
  GoogleMapController? get controller => _controller;
  Position? get deviceLocation => _deviceLocation;
  String? get deviceAddress => _deviceAddress;
  Set<Marker>? get markers => _markers;

  MapProvider() {
    _cameraPos = null;
    _deviceLocation = null;
    _deviceAddress = null;
    _markers = {};
    setCustomPin();

    if (kDebugMode) {
      print('=====///=============///=====');
      print('Map provider loaded');
      print('///==========///==========///');
    }
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

  Future<void> initializeMap() async {
    Position? deviceLocation;
    LatLng? cameraLatLng;

    if (await _locationService.checkLocationPermission()) {
      try {
        deviceLocation = await _locationService.getLocation();
      } catch (error) {
        if (kDebugMode) {
          print('=====///=============///=====');
          print('Unable to get device location');
          print('///==========///==========///');
        }
      }
    }

    if (deviceLocation != null) {
      cameraLatLng = LatLng(
        deviceLocation.latitude,
        deviceLocation.longitude,
      );
      setDeviceLocation(deviceLocation);
      setDeviceLocationAddress(
        deviceLocation.latitude,
        deviceLocation.longitude,
      );
    } else {
      cameraLatLng = const LatLng(37.42227936982647, -122.08611108362673);
    }

    setCameraPosition(cameraLatLng);

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

  void setDeviceLocationAddress(double latitude, double longitude) {
    placemarkFromCoordinates(latitude, longitude)
        .then((List<Placemark> places) {
      _deviceAddress = places[2].name;

      if (kDebugMode) {
        print(places[2].toString());
      }
    });
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

  Future<void> showTrip(LatLng pickup, LatLng destination) async {
    addMarker(pickup, _personPin!);
    addMarker(destination, _selectionPin!);

    notifyListeners();
  }
}
