import 'package:latlong2/latlong.dart';

class Event {
  final String id;
  final String title;
  final DateTime dateTime;
  final LatLng location;

  Event({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
  });
}
