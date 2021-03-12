import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:insurance/models/kaza_kaydi.dart';
import 'package:intl/intl.dart';
import './policy_screen.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class KazaScreen extends StatefulWidget {
  static const routeName = '/kaza-screen';

  @override
  _KazaScreenState createState() => _KazaScreenState();
}

class _KazaScreenState extends State<KazaScreen> {
  final _descController = TextEditingController();
  File imageFile;
  final Geolocator geolocator = Geolocator();
  final _form = GlobalKey<FormState>();
  Position _currentPosition;
  String _currentAddress;
  String img64;
  var id = '';
  var fileName = '';
  final picker = ImagePicker();

  var _editedData = KazaKaydi(
      policy: '',
      location: '',
      desc: '',
      image: null,
      filename: '',
      mimetype: '',
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  Future<void> myShowDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 100,
              width: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  (_descController.text.isEmpty ||
                          imageFile == null ||
                          _currentAddress == null)
                      ? Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 40,
                        )
                      : Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 40,
                        ),
                  Text(
                    (_descController.text.isEmpty ||
                            imageFile == null ||
                            _currentAddress == null)
                        ? "Alanlar boş bırakılamaz!"
                        : "Onaylandı",
                    textScaleFactor: 1.5,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> _saveForm() async {
    if (_descController.text.isEmpty ||
        imageFile == null ||
        _currentAddress == null) return myShowDialog();

    _form.currentState.save();
    final isEdit = await _editedData.addKazaKaydi(_editedData);
    if (isEdit) {
      myShowDialog();
      Navigator.of(context).pop();
    }
  }

  _openGallery(BuildContext context) async {
    var picture = await picker.getImage(source: ImageSource.gallery);
    if (picture == null) return;
    this.setState(() {
      imageFile = File(picture.path);
    });
    fileName = path.basename(picture.path);
    final bytes = imageFile.readAsBytesSync();
    img64 = base64Encode(bytes);
    _editedData = KazaKaydi(
        policy: id,
        desc: _editedData.desc,
        location: _currentPosition.toString(),
        filename: fileName,
        image: img64,
        mimetype: 'image\/png',
        date: _editedData.date);
    Navigator.of(context, rootNavigator: true).pop();
  }

  _openCamera(BuildContext context) async {
    var picture = await picker.getImage(source: ImageSource.camera);
    if (picture == null) return;
    this.setState(() {
      imageFile = File(picture.path);
    });
    fileName = path.basename(picture.path);
    final bytes = imageFile.readAsBytesSync();
    img64 = base64Encode(bytes);
    _editedData = KazaKaydi(
        policy: id,
        desc: _editedData.desc,
        location: _currentPosition.toString(),
        filename: fileName,
        image: img64,
        mimetype: 'image/png',
        date: _editedData.date);
    Navigator.of(context).pop();
  }

  Future<void> showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Seçiniz'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text('Gallery'),
                    onTap: () {
                      _openGallery(context);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                  GestureDetector(
                    child: Text('Camera'),
                    onTap: () {
                      _openCamera(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _getCurrentLocation(String id) async {
    Position position = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _currentPosition = position;
    });
    _editedData = KazaKaydi(
        policy: id,
        location: _currentPosition.toString(),
        date: _editedData.date);
    getAddressFromLatLng();
  }

  getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    id = ModalRoute.of(context).settings.arguments;
    final name = PolicyScreen().outputText(id);
    return Scaffold(
      appBar: AppBar(
        title: Text('Kaza İhbar Kaydı'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: name),
                enabled: false,
              ),
              Row(
                children: <Widget>[
                  Text("Konum: "),
                  FlatButton.icon(
                      textColor: Colors.blueAccent,
                      icon: Icon(
                        Icons.location_on,
                      ),
                      label: Text(
                        'Mevcut Konumu Kullan',
                      ),
                      onPressed: () {
                        _getCurrentLocation(id);
                      }),
                ],
              ),
              _currentAddress != null
                  ? Text(_currentAddress)
                  : Text('Konum Giriniz'),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 150,
                    height: 200,
                    margin: EdgeInsets.only(
                      top: 8,
                      right: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: imageFile != null
                        ? Image.file(
                            imageFile,
                            width: double.infinity,
                          )
                        : Center(child: Text('Fotoğraf Seçilmedi')),
                  ),
                  FlatButton.icon(
                    icon: Icon(Icons.photo_camera),
                    textColor: Colors.blueAccent,
                    label: Text('Fotoğraf Ekle'),
                    onPressed: () {
                      showChoiceDialog(context);
                    },
                  )
                ],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Hasar Açıklama'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                controller: _descController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide a value.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedData = KazaKaydi(
                      policy: id,
                      desc: value,
                      location: _currentPosition.toString() != null
                          ? _editedData.location
                          : _currentPosition.toString(),
                      filename: fileName,
                      image: img64,
                      mimetype: 'image\/png',
                      date: _editedData.date);
                },
              ),
              RaisedButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text(
                    'Onayla',
                  ),
                  onPressed: () {
                    _saveForm();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
