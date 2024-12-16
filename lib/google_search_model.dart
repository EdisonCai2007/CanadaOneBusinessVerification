// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:developer';

import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

const String URL = "https://www.google.com/search";

Future<List<dynamic>> searchGoogle(q, gs_lcrp) async {

  try {
    http.Response response = await http.get(
      Uri.parse(
          '$URL?q=$q&gs_lcrp=$gs_lcrp&sourceid=chrome&ie=UTF-8'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      return lookupWebsite(dom.Document.html(response.body));
    } else {
      throw Exception('Failed');
    }
  } catch (e) {
    throw Exception(e);
  }
}

List<dynamic> lookupWebsite(fetchedData) {
  return fetchedData.querySelectorAll("h3")
      .map((element) => element.parent.parent.parent.attributes['href'])
      .toList();
}

//element.children.isNotEmpty ? element.children0.attributes['href'] : null