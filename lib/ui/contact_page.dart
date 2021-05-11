import 'dart:io';

import 'package:auto_mecanica/utils/contact_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
 /* const ContactPage({Key key}) : super(key: key);*/

  final Contact contact;
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEdited = false;
  Contact _editedContact;

  @override
  void initState() {
    super.initState;
    if(widget.contact == null){
      _editedContact = Contact();
    }else{
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _phoneController.text = _editedContact.phone;
      _modelController.text = _editedContact.model;
      _yearController.text = _editedContact.year;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue[900],
            title: Text(_editedContact.name ?? "Novo Contato"),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              if( _editedContact.name != null && _editedContact.name.isNotEmpty){
                Navigator.pop(context, _editedContact);
              }else{
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.blue[900],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: _editedContact.img != null ?
                            FileImage(File(_editedContact.img)) :
                            AssetImage("images/car.png"),
                            fit: BoxFit.cover
                        )
                    ),
                  ),
                  onTap: (){
                    ImagePicker.pickImage(source: ImageSource.camera).then((file){
                      if(file == null) return;
                      setState(() {
                        _editedContact.img = file.path;
                      });
                    });
                  },
                ),
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(labelText: "Nome"),
                  onChanged: (text){
                    _userEdited = true;
                    setState(() {
                      _editedContact.name = text;
                    });
                  },
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Telefone"),
                  onChanged: (text){
                    _userEdited = true;
                    _editedContact.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _modelController,
                  decoration: InputDecoration(labelText: "Modelo"),
                  onChanged: (text){
                    _userEdited = true;
                    _editedContact.model = text;
                  },
                ),
                TextField(
                  controller: _yearController,
                  decoration: InputDecoration(labelText: "Ano"),
                  onChanged: (text){
                    _userEdited = true;
                    _editedContact.year = text;
                  },
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
    );
  }

  Future<bool> _requestPop() async {
     if(_userEdited){
       showDialog(context: context,
           builder: (context){
            return AlertDialog(
              title: Text("Descartar as alterações?"),
              content: Text("Se sarir as alterações serão perdidas."),
              actions: [
                FlatButton(onPressed: (){
                  Navigator.pop(context);
                }, child: Text("Cancelar")),
                FlatButton(onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                }, child: Text("Sim")),
              ],
            );
           }
          );
       return Future.value(false);
     }else{
       return Future.value(true);
     }
  }

}
