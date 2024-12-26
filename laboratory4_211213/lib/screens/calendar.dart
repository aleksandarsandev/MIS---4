import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/event_provider.dart';
import 'event_form.dart';
import 'map.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Schedule for Exams',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4.0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.map,
              color: Colors.white,
              size: 28.0,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => MapScreen()),
              );
            },
            tooltip: 'Open Map',
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16.0),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.blueAccent,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                return eventProvider.getEventsByDate(day);
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                defaultTextStyle: TextStyle(
                  color: Colors.black,
                ),
                outsideTextStyle: TextStyle(
                  color: Colors.grey,
                ),
                isTodayHighlighted: true,
                markersMaxCount: 3,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Colors.blueAccent,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.blueAccent,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                weekendStyle: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              availableGestures: AvailableGestures.all,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: events.map((event) {
                          return Container(
                            width: 6.0,
                            height: 6.0,
                            margin: EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: eventProvider
                    .getEventsByDate(_selectedDay ?? _focusedDay)
                    .length,
                itemBuilder: (context, index) {
                  final event = eventProvider
                      .getEventsByDate(_selectedDay ?? _focusedDay)[index];
                  return Card(
                    margin:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4.0,
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(
                          Icons.event,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        event.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${event.dateTime.toLocal()}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Location: (${event.location.latitude}, ${event.location.longitude})',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => EventFormScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
