import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

const String BASEURL = "https://nominatim.openstreetmap.org/search?q=";


Future<String> fetchAddress(String location) async {
  //
  try {
    http.Response response = await http.get(
      Uri.parse('$BASEURL$location&format=json&addressdetails=1'),
      headers: {
        'Content-Type': 'application/json',
      }
    );

    if (response.statusCode == 200) {
      //print(json.decode(response.body));
      //print(json.decode(response.body)[0]['address']['country']);
      return json.decode(response.body)[0]['address']['country'];
    } else {
      return '';
    }
  } catch (e) {
    return '';
  }
}