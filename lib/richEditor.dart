import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';


class RichEditorPage extends StatefulWidget{
  RichEditorPage({Key key, this.title, this.docData}) : super(key: key);
  final String title;
  final Delta docData;

  @override
  _RichEditorState createState() => new _RichEditorState();
}

class _RichEditorState extends State<RichEditorPage> {
  ZefyrController _controller;
  FocusNode _focusNode = new FocusNode();
  StreamSubscription<NotusChange> _sub;
  
  @override
  void initState() {
    super.initState();
    if (widget.docData != null){
      _controller = ZefyrController(NotusDocument.fromDelta(widget.docData));
    }else{
      _controller = ZefyrController(NotusDocument());
    }
    _sub = _controller.document.changes.listen((change) {
      print('${change.source}: ${change.change}');
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: true,
        appBar: AppBar(
          elevation: 1.0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          title: Text(widget.title),
          actions: <Widget>[
            new FlatButton(
              onPressed: _stopEditing, child: Text('DONE', style: TextStyle(color: Colors.white),)
            )
          ],
        ),
        body: ZefyrScaffold(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildEditor(),
          ),
        ),
      )
    );
  }

  Widget buildEditor() {
    final theme = new ZefyrThemeData(
      toolbarTheme: ZefyrToolbarTheme.fallback(context).copyWith(
        color: Colors.grey.shade800,
        toggleColor: Colors.grey.shade900,
        iconColor: Colors.white,
        disabledIconColor: Colors.grey.shade500,
      ),
    );

    return ZefyrTheme(
      data: theme,
      child: ZefyrEditor(
        padding: EdgeInsets.all(8.0),
        controller: _controller,
        focusNode: _focusNode,
        autofocus: false,
        imageDelegate: new CustomImageDelegate(),
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  void _stopEditing(){
    Navigator.pop(context, _controller.document.toDelta());
  }
}

class CustomImageDelegate extends ZefyrDefaultImageDelegate {
  @override
  Widget buildImage(BuildContext context, String imageSource) {
    // We use custom "asset" scheme to distinguish asset images from other files.
    if (imageSource.startsWith('asset://')) {
      final asset = new AssetImage(imageSource.replaceFirst('asset://', ''));
      return new Image(image: asset);
    } else {
      return super.buildImage(context, imageSource);
    }
  }
}