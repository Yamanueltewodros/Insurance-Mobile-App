import 'package:flutter/material.dart';
import 'package:insurance/models/policyHolder.dart';
import 'package:http/http.dart' as http;
import 'package:insurance/screens/kaza_kaydi_screen.dart';
import 'package:xml/xml.dart' as xml;
import 'package:html_unescape/html_unescape.dart';

class PolicyDetail extends StatelessWidget {
  static const routeName = '/policy-detail';

  var unescape = new HtmlUnescape();
  List<PolicyHolder> list2 = [];

  Future<List<PolicyHolder>> _getPolicyData(
      BuildContext context, String id) async {
    try {
      PolicyHolder p;

      var envelope =
          "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:com=\"http://com\"><soapenv:Header/><soapenv:Body><com:getPolicyHolder><com:policy_holder_id>$id</com:policy_holder_id></com:getPolicyHolder></soapenv:Body></soapenv:Envelope>";
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
      var elements = raw.findAllElements('PolicyHolder');
      elements.map((e) {
        p = PolicyHolder(
          e.findElements("policy_holder_id").first.text,
          e.findElements("first_name").first.text,
          e.findElements("last_name").first.text,
          e.findElements("birth_date").first.text,
          e.findElements("address").first.text,
          e.findElements("city_code").first.text,
          e.findElements("password").first.text,
          e.findElements("account_name").first.text,
        );
        list2.add(p);
      }).toList();
    } catch (e) {
      return null;
    }
    return list2;
  }

  Widget myData(String input, String output) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Text(
            input,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(output),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(title: Text('Policy Detail')),
      body: Container(
        height: 600,
        child: FutureBuilder(
          future: _getPolicyData(context, id),
          builder: (context, data) {
            if (data.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (data.data.length == 0)
              return Center(child: Text('Police Bilgisi Bulunmamaktadır'));
            if (data.data != null) {
              List<PolicyHolder> list = data.data;
              return ListView.builder(
                itemBuilder: (content, index) {
                  return Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        child: Card(
                          child: Column(
                            children: <Widget>[
                              myData(
                                  'Adı Soyadı: ',
                                  list[index].first_name +
                                      ' ' +
                                      list[index].last_name),
                              myData('Doğum Tarihi: ', list[index].birth_date),
                              myData('Adres: ', list[index].address.trim()),
                              myData('Şehir Kodu: ', list[index].city_code),
                              myData('Hesap Adı: ', list[index].account_name),
                            ],
                          ),
                          elevation: 5,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(left: 10),
                        child: RaisedButton.icon(
                          icon: Icon(Icons.assignment),
                          color: Colors.blue,
                          textColor: Colors.white,
                          label: Text('Kaza Kaydı Görüntüleme'),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                KazaKaydiScreen.routeName,
                                arguments: id);
                          },
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(left: 10),
                        child: RaisedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('Yenileme                            '),
                          onPressed: () {},
                          color: Colors.blue,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
                itemCount: list.length,
              );
            }
          },
        ),
      ),
    );
  }
}
