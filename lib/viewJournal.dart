import 'package:dream_keeper/richEditor.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';
import 'package:dream_keeper/models/journal.dart';

class ViewJournalPage extends StatefulWidget{
  ViewJournalPage({Key key, this.journal}) : super(key: key);
  final Journal journal;
  final formatter = new DateFormat("EEEE, MMMM d, yyyy ");

  @override
  _ViewJournalState createState() => new _ViewJournalState();
}

class _ViewJournalState extends State<ViewJournalPage> {
  @override
  Widget build(BuildContext context) {
    
    NotusDocument notusDoc =NotusDocument.fromJson(json.decode(widget.journal.journalEntry));
    final form = ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0,10.0,0.0,10.0),
          child: Text('Journal Entry from ' + widget.formatter.format(widget.journal.datetime).toString(), 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              fontSize: 18
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ZefyrView(
            document: notusDoc,
            imageDelegate: CustomImageDelegate(),
          ),
        ),
      ],
    );

    return new WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          elevation: 1.0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          title: Text(widget.journal.title),
          actions: <Widget>[
            new FlatButton(
              onPressed: ()=>{
                    Navigator.pop(context)
              }, child: Text('CLOSE', style: TextStyle(color: Colors.white),)
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: form,
        ),
      ),
    );
  }
}
