import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

const String BASEURL = "https://api.openai.com/v1/threads";
const String MESSAGEURL = "/messages";
const String CREATERUNURL = "/runs";

String threadID = '';

Future<void> createThread() async {
  try {
    http.Response response = await http.post(
      Uri.parse(BASEURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.get('API_KEY')}',
        'OpenAI-Beta': 'assistants=v2',
      },
      body: '',
    );

    if (response.statusCode == 200) {
      threadID = json.decode(response.body)['id'];
    }
  } catch (e) {
    throw Exception(e);
  }
}


Future<String> addMessage(String content) async {
  try {
    http.Response response = await http.post(
      Uri.parse('$BASEURL/$threadID$MESSAGEURL'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.get('API_KEY')}',
        'OpenAI-Beta': 'assistants=v2',
      },
      body: json.encode({
        "role": "user",
        "content": content
      }
    ));

    // log(response.body);
    return response.body;
  } catch (e) {
    throw Exception(e);
  }
}

Future<String> createRun() async {
  try {
    http.Response response = await http.post(
      Uri.parse('$BASEURL/$threadID$CREATERUNURL'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.get('API_KEY')}',
        'OpenAI-Beta': 'assistants=v2',
      },
      body: json.encode({
        'assistant_id': dotenv.get('ASSISTANT_ID'),
        //'instructions': 'Only say YES or NO. If no, explain why.'
      }
    ));

    // log(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed');
    }
  } catch (e) {
    throw Exception(e);
  }
}

Future<String> printMessage() async {
  try {
    http.Response response = await http.get(
      Uri.parse('$BASEURL/$threadID$MESSAGEURL'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.get('API_KEY')}',
        'OpenAI-Beta': 'assistants=v2',
      },  
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'][0]['content'][0]['text']['value'];
    } else {
      throw Exception('Failed');
    }
  } catch (e) {
    throw Exception(e);
  }
}

Future<String> aiReview(List<dynamic> client) async {
  await addMessage('${client[1]}\n${client[2]}');
  await Future.delayed(const Duration(milliseconds: 500), () => createRun());
  return await Future.delayed(const Duration(seconds: 10), () => printMessage());
}