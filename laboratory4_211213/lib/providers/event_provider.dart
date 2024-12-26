import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/event.dart';

class EventProvider with ChangeNotifier {
  final List<Event> _events = [];

  List<Event> get events => [..._events];

  void addEvent(String title, DateTime dateTime, LatLng location) {
    final newEvent = Event(
      id: DateTime.now().toString(),
      title: title,
      dateTime: dateTime,
      location: location,
    );
    _events.add(newEvent);
    notifyListeners();
  }

  List<Event> getEventsByDate(DateTime date) {
    return _events.where((event) {
      return event.dateTime.year == date.year &&
          event.dateTime.month == date.month &&
          event.dateTime.day == date.day;
    }).toList();
  }
}
