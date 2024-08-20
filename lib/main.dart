import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  final _future =
      Supabase.instance.client.from('appointment').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supabase Calendar'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final countries = snapshot.data!;
          return SfCalendar(
            view: CalendarView.timelineWeek,
            dataSource: AppointmentDataSource(
                countries
                    .map((e) => Appointment.fromSnapShot(e, Colors.blue))
                    .toList(),
                countries
                    .map((e) => CalendarResource(
                        id: '000${e['id']}', displayName: 'User${e['id']}'))
                    .toList()),
          );
        },
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(
      List<Appointment> source, List<CalendarResource> resourceColl) {
    appointments = source;
    resources = resourceColl;
  }
  @override
  DateTime getStartTime(int index) {
    return appointments![index].from!;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to!;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName!;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background!;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay!;
  }

  @override
  List<Object> getResourceIds(int index) {
    return appointments![index].resourceIds!;
  }
}

class Appointment {
  String? eventName;
  DateTime? from;
  DateTime? to;
  Color? background;
  bool? isAllDay;
  List<Object>? resourceIds;

  Appointment({
    this.eventName,
    this.from,
    this.to,
    this.background,
    this.isAllDay,
    this.resourceIds,
  });

  static Appointment fromSnapShot(
      Map<String, dynamic> dataSnapshot, Color color) {
    return Appointment(
      eventName: dataSnapshot['subject'],
      from: DateTime.parse(dataSnapshot['endTime']),
      to: DateTime.parse(dataSnapshot['startTime']),
      background: color,
      isAllDay: false,
      resourceIds: ['000${dataSnapshot['resourceId']}'],
    );
  }
}
