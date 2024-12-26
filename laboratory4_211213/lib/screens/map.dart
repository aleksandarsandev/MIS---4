import 'dart:convert'; // For parsing JSON response

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:laboratory4_211213/providers/event_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController _mapController = MapController();
  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
        ),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permissions are denied.'),
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permissions are permanently denied.'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, 12.0);
      }
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get current location: $e'),
        ),
      );
    }
  }

  Future<void> _fitToCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 16.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Current location not available.'),
        ),
      );
    }
  }

  Future<void> _getRoute(LatLng end) async {
    try {
      final response = await http.get(Uri.parse(
          'http://router.project-osrm.org/route/v1/driving/'
              '${_currentLocation?.longitude},${_currentLocation?.latitude};'
              '${end.longitude},${end.latitude}'
              '?overview=full&geometries=geojson'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates =
          data['routes'][0]['geometry']['coordinates'] as List;

          setState(() {
            _routePoints = coordinates
                .map(
                    (coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
                .toList();
          });
        }
      } else {
        throw Exception('Failed to load route');
      }
    } catch (e) {
      print('Error fetching route: $e');
      throw Exception('Error fetching route');
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;

    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation,
              zoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: events.map((event) {
                  return Marker(
                    width: 40.0,
                    height: 40.0,
                    point: LatLng(event.location.latitude, event.location.longitude),
                    child: GestureDetector(
                      onTap: () async {
                        print('Event marker tapped: ${event.location.latitude}, ${event.location.longitude}');
                        try {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(event.title),
                                content: Text(
                                  'Date: ${event.dateTime.toLocal()}\n'
                                      'Location: (${event.location.latitude}, ${event.location.longitude})',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (_currentLocation != null) {
                            await _getRoute(LatLng(event.location.latitude, event.location.longitude));
                          }
                        } catch (e) {
                          print('Error calculating route: $e');
                        }
                      },
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  );
                }).toList(),
              ),

              MarkerLayer(
                markers: [
                  if (_currentLocation != null)
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: _currentLocation!,
                      child: Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40.0,
                      ),
                    ),
                ],
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 3.0,
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _fitToCurrentLocation,
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
