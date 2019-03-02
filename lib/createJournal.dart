import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:dream_keeper/richEditor.dart';
import 'package:zefyr/zefyr.dart';

class CreateJournalPage extends StatefulWidget{
  CreateJournalPage({Key key, this.title, this.date}) : super(key: key);
  final String title;
  final DateTime date;
  final formatter = new DateFormat("EEEE, MMMM d, yyyy ");


  @override
  _CreateJournalState createState() => new _CreateJournalState();
}

class _CreateJournalState extends State<CreateJournalPage> {
  // var doc = NotusDocument();
  var notusDoc = NotusDocument();
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = 'Journal Entry for ' + widget.formatter.format(widget.date).toString();
  }

  @override
  Widget build(BuildContext context) {
    final form = ListView(
      children: <Widget>[
        TextFormField(
          autofocus: false,
          controller: _titleController,
          decoration: InputDecoration(labelText: 'Title'),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ZefyrView(
            document: notusDoc,
            imageDelegate: new CustomImageDelegate(),
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
          title: Text(widget.title),
          actions: <Widget>[
            
            new FlatButton(
              onPressed: _save, child: Text('SAVE', style: TextStyle(color: Colors.white),)
            ),
            new FlatButton(
              onPressed: ()=>{
                    Navigator.pop(context)
              }, child: Text('CANCEL', style: TextStyle(color: Colors.white),)
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: form,
        ),
        bottomNavigationBar: ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                richEditorbutton(context);
              },
              child: new Text('Edit Journal Entry'),
              color: Colors.blue,
              textColor: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  void _save(){
    Map<String,String> newEvent = {
      'title': _titleController.text,
      'journal':notusDoc.toString() 
    };
    Navigator.pop(context, newEvent);
  }

  void richEditorbutton(BuildContext context) async{
    print("rich editor Btn Pressed");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return new RichEditorPage(title: 'Journal', docData: notusDoc.toDelta(),);
        }
    ));
    setState(() {
      notusDoc = NotusDocument.fromDelta(result);
    });
  }
}
