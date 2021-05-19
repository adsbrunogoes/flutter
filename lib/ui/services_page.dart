import 'package:auto_mecanica/utils/service_utils.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ServicePage extends StatefulWidget {
  //const ServicePage({Key key}) : super(key: key);

  final Service service;
  final int idContact;

  ServicePage({this.service, this.idContact});

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final _toDoController = TextEditingController();
  ServicesUtils utils = ServicesUtils();
  Service service;

  List _toDoList = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();

    setState(() {
      _getAllServices();
    });
  }

  void _addToDo() {
    service = Service();
    service.title = _toDoController.text;
    service.check = 0;
    service.idContact = widget.idContact;
    utils.saveService(service);
    _getAllServices();
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });

      _saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Serviços"),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  controller: _toDoController,
                  decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blue[900])),
                )),
                RaisedButton(
                  color: Colors.blue[900],
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _toDoList.length,
                  itemBuilder: buildItem),
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index].title),
        value: _toDoList[index].check == 1,
        secondary: CircleAvatar(
          child: Icon(_toDoList[index].check == 1 ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _toDoList[index].check = c ? 1 : 0;
            utils.updateService(_toDoList[index]);
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          utils.deleteService(_toDoList[index].id);
        });
        _getAllServices();
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);

    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  void _getAllServices() {
    //super.initState();
    utils.getAllServices(widget.idContact).then((list) {
      setState(() {
        _toDoList = list;
      });
    });
  }
}
