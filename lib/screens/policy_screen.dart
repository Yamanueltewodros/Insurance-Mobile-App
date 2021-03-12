import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:insurance/models/policy.dart';
import 'package:insurance/screens/policy_detail.dart';
import 'package:insurance/screens/kaza_screen.dart';
import 'package:xml/xml.dart' as xml;
import 'package:html_unescape/html_unescape.dart';

enum policyStatus { Proposal, Policy, Cancelled, Expired }
enum productCode { Kasko, Trafik, Yangin, Deprem }

class PolicyScreen extends StatelessWidget {
  String outputSubtext(String statusCode) {
    if (statusCode == '1')
      statusCode = 'Proposal';
    else if (statusCode == '2')
      statusCode = 'Policy';
    else if (statusCode == '3')
      statusCode = 'Cancelled';
    else if (statusCode == '4') {
      statusCode = 'Expired';
    }
    return statusCode;
  }

  String outputText(String productCode) {
    if (productCode == '1')
      productCode = 'Kasko';
    else if (productCode == '2')
      productCode = 'Trafik';
    else if (productCode == '3')
      productCode = 'Yangin';
    else if (productCode == '4') {
      productCode = 'Deprem';
    }
    return productCode;
  }

  var unescape = new HtmlUnescape();
  List<Policy> listo = [];

  var envelope =
      "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:com=\"http://com\"> <soapenv:Header/> <soapenv:Body> <com:getPolicy/> </soapenv:Body> </soapenv:Envelope>";

  Future<List<Policy>> _getData(BuildContext context) async {
    Policy p;
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
    var elements = raw.findAllElements('Policy');
    elements.map((e) {
      p = Policy(
        e.findElements("policy_no").first.text,
        e.findElements("policy_holder_id").first.text,
        e.findElements("start_date").first.text,
        e.findElements("end_date").first.text,
        e.findElements("premium").first.text,
        e.findElements("product_code").first.text,
        e.findElements("plate_no").first.text,
        e.findAllElements("policy_status").first.text,
      );
      listo.add(p);
    }).toList();
    return listo;
  }

  void selectPolicy(BuildContext context, String id) {
    Navigator.of(context).pushNamed(PolicyDetail.routeName, arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Policy'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Container(
                height: 600,
                width: double.infinity,
                child: FutureBuilder(
                  future: _getData(context),
                  builder: (context, data) {
                    if (data.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (data.data != null) {
                      List<Policy> list = data.data;
                      return ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => selectPolicy(
                                  context, list[index].policy_holder_id),
                              child: Card(
                                elevation: 5,
                                child: Container(
                                  child: ListTile(
                                    trailing: IconButton(
                                      icon: Icon(Icons.add_box),
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                            KazaScreen.routeName,
                                            arguments: list[index].policy_no);
                                      },
                                    ),
                                    title: Text(
                                      '${list[index].policy_no}' +
                                          ' ' +
                                          outputText(list[index].product_code),
                                    ),
                                    subtitle: Text(
                                        '${list[index].start_date + '/' + list[index].end_date}' +
                                            ' ' +
                                            outputSubtext(
                                                list[index].policy_status)),
                                  ),
                                ),
                              ),
                            );
                          });
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
