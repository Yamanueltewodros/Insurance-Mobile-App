import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';

class KazaKaydi with ChangeNotifier {
  final String policy;
  final String desc;
  final String location;
  final String date;
  final String image;
  final String filename;
  final String mimetype;

  KazaKaydi(
      {this.policy,
      this.location,
      this.desc,
      this.date,
      this.filename,
      this.image,
      this.mimetype});
  var unescape = new HtmlUnescape();
  Future<bool> addKazaKaydi(KazaKaydi data) async {
    var envelope =
        "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:com=\"http://com\"><soapenv:Header/><soapenv:Body><com:kazaKaydi><com:policy_no>$policy</com:policy_no><com:location>$location</com:location><com:damage_desc>$desc</com:damage_desc><com:damage_date>$date</com:damage_date><com:image>$image</com:image><com:filename>$filename</com:filename><com:mimetype>$mimetype</com:mimetype></com:kazaKaydi></soapenv:Body></soapenv:Envelope>";
    var res = unescape.convert(envelope);
    http.Response response =
        await http.post('http://10.0.2.2:8080/SoapRealDatabase/services/tsdt',
            headers: {
              "Content-Type": "text/xml;charset=UTF-8",
              "SOAPAction": "",
              "Host": "localhost:8080",
            },
            body: res);
    print(res);
    notifyListeners();
    return true;
  }
}
