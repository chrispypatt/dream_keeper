import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dream_keeper/createJournal.dart';
import 'package:table_calendar/table_calendar.dart';


void main() async {
  runApp(new DreamKeeperApp());
}


class DreamKeeperApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Dream Keeper',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: new MainPage(title: 'Dream Keeper'),
      routes: <String, WidgetBuilder> { 
        '/createJournal': (BuildContext context) => new CreateJournalPage(title: 'New Journal Entry'), 
      },
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime _selectedDay;
  Map<DateTime, List> _journals;
  List _selectedJournals;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _journals = getJournals(); 
    _selectedJournals = _journals[_selectedDay] ?? [];
  }
    
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          resizeToAvoidBottomPadding: false,
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _buildTableCalendar(),
              const SizedBox(height: 8.0),
              Expanded(child: _buildJournalList()),
            ],
          ),
          floatingActionButton: new FloatingActionButton(
            onPressed: () {
              createJournalbutton(context);
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        );
      }
    );
  }

  void createJournalbutton(BuildContext context) async {
    print("CreateJournal Btn Pressed");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => 
        CreateJournalPage(title: 'New Journal Entry', date: _selectedDay))
    );
    setState(() { 
      if (result!=null){
        if (_journals[_selectedDay] == null){
          _journals[_selectedDay] = [];
        }
        _journals[_selectedDay].add(result);
        _selectedJournals =_journals[_selectedDay];
      }
    });
  }
    
  // Configure the calendar here
  Widget _buildTableCalendar() {
    return Container(
      decoration: BoxDecoration(
        border: new BorderDirectional(
            bottom: new BorderSide(
              color: Colors.black54,
              width: 5.0,
              style: BorderStyle.solid
            ),

          ),
      ),
      child: TableCalendar(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.redAccent[200],
        eventMarkerColor: Colors.brown[700],
        calendarFormat: CalendarFormat.month,
        centerHeaderTitle: true,
        formatToggleVisible: false,
        formatToggleTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatToggleDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
        events: _journals,
        onDaySelected: (day) {
          setState(() {
            _selectedDay = day;
            _selectedJournals = _journals[_selectedDay] ?? [];
          });
        },
      ),
    );
  }

  Widget _buildJournalList() {
    return ListView(
      children: _selectedJournals
          .map((journal) => Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.black38,
                      offset: Offset(1.0, 2.0)
                    )
                  ],
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.blue,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(journal['title'], style: TextStyle(color: Colors.white),),
                  onTap: () => print('$journal tapped!'),
                ),
              ))
          .toList(),
    );
  }

  Map<DateTime, List> getJournals() {
    return Map<DateTime, List>();
  }
}
    
