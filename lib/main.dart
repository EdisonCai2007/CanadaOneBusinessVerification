import 'dart:convert';
import 'dart:io';

import 'package:bizzone_website_verifier/address_verification.dart';
import 'package:bizzone_website_verifier/openai_model.dart';
import 'package:bizzone_website_verifier/website_scraper_model.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

List<List<String>> clients = [];
List<List<String>> postalCodes = [];
List<List<String>> validity = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canadian Business Verification',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CanadaOne Business Verification'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
    loader();
  }

  void loader() async {
    await dotenv.load(fileName: '.env');

    clients = const CsvToListConverter().convert(await DefaultAssetBundle.of(context).loadString('assets/canadaone.csv'), eol: "\n",shouldParseNumbers: false);

    postalCodes = const CsvToListConverter().convert(await DefaultAssetBundle.of(context).loadString('assets/postal_codes.csv'), eol: "\n", shouldParseNumbers: false);
  }

  void runVerification(zipCode, address, website, phoneNumber, ai) async {
    final List<dynamic> _postalCodes = postalCodes.skip(1).map((row) => row[0]).toList(growable: true);

    // Boot AI Review
    await createThread();

    for (int i = 1; i < 100; i++) {
      int score = 0;

      clients[i][10] = clients[i][10].trim().toUpperCase();

      // Zip Verification
      if (zipCode && clients[i][10].contains(' ')) {
        String areaCode = ((clients[i][10].split(' ').length == 2) ? clients[i][10].substring(0,3) : clients[i][10].substring(clients[i][10].indexOf(' '),clients[i][10].lastIndexOf(' '))).trim();

        //print('${clients[i][10].trim()} | $areaCode');
        if (_postalCodes.contains(areaCode)) score += 5;
      } else if (clients[i][10].length >= 3) {
        if (_postalCodes.contains(clients[i][10].substring(0,3))) score += 5;
      }

      // Address Verification
      if (address && (await fetchAddress(clients[i].sublist(6,7).join(' '))).contains('Canada')) {
        score += 7;
      }

      // Website Verification
      if (website) {
        if (clients[i][2].contains('.ca')){
          score += 10;
        } else if (clients[i][2].contains('.com')) {
          score += 3;
        }
      }

      // Phone Number Verification
      if (phoneNumber && await parsePhoneNumber(clients[i][2])) score += 7;

      // AI Review Verification
      if (ai) {
        await aiReview(clients[i]).then((value) {
          //print('${clients[i][1]} $value');
          if (value.contains('YES')) score += 10;
        });
      }

      //print(score);
      if (score >= 13) {
        print('valid $score ${clients[i][2]}');
        validity.add(['VALID!']);
      } else {
        print('invalid $score ${clients[i][2]}');
        validity.add(['INVALID!']);
      }
    }

    String csv = const ListToCsvConverter().convert(validity);

    File file = File('/Users/edisoncai/Documents/DevelopmentProjects/bizzone_website_verifier/assets/validity.csv');
    file.writeAsString(csv);
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        title: Text(widget.title),
      ),
      body: Center(
        child: FloatingActionButton(
          onPressed: () {
            runVerification(
              true, // Zip Code Verification
              true, // Address Verification
              true, // Website Verification
              true, // Phone Number Verification
              false, // AI Review Verification
            );
          },
          tooltip: 'Increment',
          child:const Text('Run'),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
