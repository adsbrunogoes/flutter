import 'dart:io';
import 'package:auto_mecanica/ui/contact_page.dart';
import 'package:auto_mecanica/ui/services_page.dart';
import 'package:auto_mecanica/utils/contact_utils.dart';
import 'package:auto_mecanica/utils/service_utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactUtils utils = ContactUtils();
  List<Contact> contacts = List();

  ServicesUtils serviceUtils = ServicesUtils();
  List<Service> services = List();

  @override
  void initState() {
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clientes"),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[900],
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
          child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contacts[index].img != null
                          ? FileImage(File(contacts[index].img))
                          : AssetImage("images/car.png"),
                      fit: BoxFit.cover)),
            ),
            Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contacts[index].name ?? "",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(contacts[index].phone ?? "",
                        style: TextStyle(fontSize: 18)),
                    Text(
                      (contacts[index].model ?? "") +
                          " - " +
                          (contacts[index].year ?? ""),
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                )),
          ],
        ),
      )),
      onTap: () {
        _showServicePage(index);
      },
      onLongPress: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FlatButton(
                          child: Text("Ligar",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20)),
                          onPressed: () {
                            launch("tel:${contacts[index].phone}");
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          child: Text("Editar",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20)),
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactPage(contact: contacts[index]);
                          },
                        ),
                        FlatButton(
                          child: Text("Excluir",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20)),
                          onPressed: () {
                            _requestDel(index);
                          },
                        ),
                      ],
                    ));
              });
        });
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));
    if (recContact != null) {
      if (contact != null) {
        await utils.updateContact(recContact);
        _getAllContacts();
      } else {
        await utils.saveContact(recContact);
        _getAllContacts();
      }
    }
  }

  void _showServicePage(int index) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ServicePage(
                  idContact: contacts[index].id,
                )));
  }

  void _getAllContacts() {
    //super.initState();
    utils.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _requestDel(int index) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Deletar contato"),
            content: Text("Deseja realmente excluir esse contato?"),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar")),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    utils.deleteContact(contacts[index].id);
                    setState(() {
                      contacts.removeAt(index);
                      Navigator.pop(context);
                    });
                  },
                  child: Text("Sim")),
            ],
          );
        });
  }
}
