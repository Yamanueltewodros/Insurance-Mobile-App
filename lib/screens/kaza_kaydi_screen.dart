import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'package:insurance/models/kaza_kaydi.dart';
import 'package:insurance/screens/policy_screen.dart';
import 'package:xml/xml.dart' as xml;

class KazaKaydiScreen extends StatelessWidget {
  static const routeName = "/kaza-kaydi";

  var unescape = new HtmlUnescape();
  List<KazaKaydi> list = [];

  Future<List<KazaKaydi>> _getKazaKaydi(BuildContext context, String id) async {
    KazaKaydi k;
    try {
      var envelope =
          "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:com=\"http://com\"><soapenv:Header/><soapenv:Body><com:getKazaKaydi> <com:policy_no>$id</com:policy_no></com:getKazaKaydi></soapenv:Body></soapenv:Envelope>";
      http.Response response =
          await http.post('http://10.0.2.2:8080/SoapRealDatabase/services/tsdt',
              headers: {
                "Content-Type": "text/xml;charset=UTF-8",
                "SOAPAction": "",
                "Host": "localhost:8080",
              },
              body: envelope);
      var res = unescape.convert(response.body);
      var raw = xml.parse(res);
      var elements = raw.findAllElements('KazaKaydi');
      //print(elements);
      elements.map((e) {
        print(unescape.convert(e.findElements("image").first.text));

        k = KazaKaydi(
          policy: e.findElements("policy_no").first.text,
          location: e.findElements("location").first.text,
          desc: e.findElements("damage_desc").first.text,
          date: e.findElements("damage_date").first.text,
          filename: e.findElements("filename").first.text,
          image: e.findElements("image").first.text,
        );
        list.add(k);
      }).toList();
    } catch (e) {
      return list;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Kaza Kaydı'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 500,
            child: FutureBuilder(
                future: _getKazaKaydi(context, id),
                builder: (context, data) {
                  if (data.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (data.data.length == 0)
                    return Center(child: Text('Kaza Kaydı Bulunmamaktadır'));
                  if (data.data != null) {
                    List<KazaKaydi> list2 = data.data;
                    return ListView.builder(
                      itemBuilder: (context, i) {
                        final name = PolicyScreen().outputText(list2[i].policy);
                        //print(list2[i].image);
                        Uint8List bytes = base64.decode(list[i].image);
                        print(bytes);

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              Card(
                                child: Text(
                                    'Poliçe Adı: $name\nKonum: ${list2[i].location}\nHasar Açıklama: ${list2[i].desc}\nKaza Günü: ${list2[i].date} '),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: list2.length,
                    );
                  }
                }),
          )
        ],
      ),
    );
  }
}
