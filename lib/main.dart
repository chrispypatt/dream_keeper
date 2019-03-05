import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dream_keeper/createJournal.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dream_keeper/models/journal.dart';
import 'package:dream_keeper/stores/db.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  Map<DateTime, List<Journal>> _journals;
  List _selectedJournals;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
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
          body:  FutureBuilder<List<Journal>>(
            future: DBProvider.db.getAllJournals(),
            builder: (BuildContext context, AsyncSnapshot<List<Journal>> snapshot) {
              // if (snapshot.hasData) {
                _journals = parseJournals(snapshot.data);
                _selectedJournals = _journals[_selectedDay] ?? [];
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    _buildTableCalendar(),
                    const SizedBox(height: 8.0),
                    Text(
                      'Your Journals', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        decoration: TextDecoration.combine([
                          TextDecoration.underline,
                        ])
                      ),
                    ),
                    Expanded(child: _buildJournalList()),
                  ],
                );
              // }else{
              //   return Center(child: CircularProgressIndicator());
              // }
            }
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
        Journal journal = new Journal();
        journal.datetime = _selectedDay;
        journal.journalEntry = result['journal'];
        journal.title =result['title'];
        if (_journals[_selectedDay] == null){
          _journals[_selectedDay] = [];
        }
        _journals[_selectedDay].add(journal);
        _selectedJournals = _journals[_selectedDay];
        DBProvider.db.newJournal(journal);
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
              width: 2.0,
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
    if (_selectedJournals.isEmpty){
      return Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("Looks like you don't have any journals for this day! Tap the button below to start an entry!", textAlign: TextAlign.center,)
      );
    }
    // return Text(_selectedJournals.toString());
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
                child: Slidable(
                  delegate: new SlidableDrawerDelegate(),
                  child: ListTile(
                    title: Text(journal.title, style: TextStyle(color: Colors.white),),
                    onTap: () => print('$journal tapped!'),
                  ),
                  secondaryActions: <Widget>[
                    new Container(
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
                      child: IconSlideAction(
                      
                        caption: 'Delete',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () {
                          setState(() {
                            removeJournal(journal);
                          });
                        }
                      ),
                    )
                  ]
              )
            )
          ).toList(),
    );
  }

  void removeJournal(journal){
    _journals[_selectedDay].removeWhere((item) => item.id == journal.id);
    _selectedJournals = _journals[_selectedDay];
    DBProvider.db.deleteJournal(journal.id);
  }

  Map<DateTime, List<Journal>> getJournals() {
    Map<DateTime, List<Journal>> journalMap;
    DBProvider.db.getAllJournals().then((journalList) =>{
      journalMap = parseJournals(journalList)
    });
    return journalMap;
  }

  Map<DateTime, List<Journal>> parseJournals(journalList){
    Map<DateTime, List<Journal>> journalMap = Map<DateTime, List<Journal>>();
    if (journalList!=null){
      for (var journal in journalList) {
        if (journalMap[journal.datetime] == null){
          journalMap[journal.datetime] = [];
        }
        journalMap[journal.datetime].add(journal);
      }
    }
    return journalMap;
  }
}
    
