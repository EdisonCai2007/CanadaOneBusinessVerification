import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

const List<String> areaCodes = [
  "204", "226", "236", "249", "250", "263", "289", "306", "343", "354", 
  "365", "367", "368", "382", "403", "416", "418", "428", "431", "437", 
  "438", "450", "468", "474", "506", "514", "519", "548", "579", "581", 
  "584", "587", "604", "613", "639", "647", "672", "683", "705", "709", 
  "742", "753", "778", "780", "782", "807", "819", "825", "867", "873", 
  "879", "902", "905"
];



Future<String> fetchWebsite(String website) async {
  try {
    http.Response response = await http.get(
      Uri.parse(website),
      headers: {
        'Content-Type': 'application/json',
      },  
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return '';
    }
  } catch (e) {
    return '';
  }
}

Future<bool> parsePhoneNumber(String website) async {
  final rawData = await fetchWebsite(website);
  //log('$website $rawData');

  List<String> phoneNumbers = RegExp(
  r'(\+?[1-9]\d{0,2})?[\s\-\(\)]?(\(?\d{2,4}\)?)[\s\-\(\)]?\d{3}[\s\-\(\)]?\d{3,4}',
    caseSensitive: false,
    ).allMatches(rawData).map((e) => e.group(0)!).toList();
  //log(phoneNumbers.toString());

  bool hasSubstring = areaCodes.any((element2) =>
      phoneNumbers.any((element1) {
        if (element1.replaceAll(RegExp(r'(\+1|[^\d+])'), '').startsWith(element2.replaceAll(RegExp(r'[^\d]'), ''))) {
          //log(element2);
          return true;
        } else {
          return false;
        }
      }));
  //log('$hasSubstring $website');
  return hasSubstring;
}