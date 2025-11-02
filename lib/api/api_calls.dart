import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quran_al_kareem/api/api_urls.dart';
import 'package:quran_al_kareem/model/qari_model.dart';
import 'package:quran_al_kareem/model/quran_asad_text_model.dart';
import 'package:quran_al_kareem/model/quran_audio_model.dart';
import 'package:quran_al_kareem/model/quran_edition_model.dart';
import 'package:quran_al_kareem/model/quran_model.dart';

import '../model/surrah_model.dart' as surah;

class ApiCalls {
  //   Future<PrayerTimeModel>prayerTimes(double latitude,double longitude,String timestamp)async{
  //     print(latitude);
  //     print(longitude);
  //     print(timestamp);
  //     var url=Uri.parse("https://api.aladhan.com/v1/timings/${timestamp}?latitude=${latitude.toString()}&longitude=${longitude.toString()}&method=2");
  //     var response=await Dio(). get(url);
  // print(response.body);

  //       return PrayerTimeModel.fromJson(jsonDecode(response.body));

  //   }

  var client = http.Client();

  //Internal JSON String used
  // Future<DuaModel> getDua() async {
  //   var dua = null;

  //   var myDataString = utf8.decode(duasVar.toString());

  //   var jsonMap = json.decode(myDataString);

  //   dua = DuaModel.fromJson(jsonMap);

  //   // try {
  //   //   var jsonMap = json.decode(duasVar.toString());

  //   //   dua = DuaModel.fromJson(jsonMap);
  //   // } catch (exception) {
  //   //   print(exception);
  //   //   return dua;
  //   // }

  //   return dua;
  // }

  Future<QuranModel> getQuranText() async {
    var response = await client.get(Uri.parse(Strings.quranTextUthmaniUrl));
    var quranText = null;

    try {
      if (response.statusCode == 200) {
        var jsonString = response.body;
        var jsonMap = json.decode(jsonString);

        quranText = QuranModel.fromJson(jsonMap);
      }
    } catch (exception) {
      print(exception);
      return quranText;
    }

    return quranText;
  }

  Future<QuranEditionModel> getTestCall() async {
    var response = await client.get(
      Uri.parse('http://api.alquran.cloud/v1/edition'),
    );
    var quranText = null;

    try {
      if (response.statusCode == 200) {
        var jsonString = response.body;
        var jsonMap = json.decode(jsonString);

        quranText = QuranEditionModel.fromJson(jsonMap);
      }
    } catch (exception) {
      print(exception);
      return quranText;
    }

    return quranText;
  }

  Future<QuranTextAsad> getQuranTextAsad() async {
    var response = await client.get(Uri.parse(Strings.quranTextAsadUrl));
    print(response.body);
    var quranText;

    var jsonString = response.body;
    var jsonMap = json.decode(jsonString);

    quranText = QuranTextAsad.fromJson(jsonMap);
    print("Call Success: " + quranText);
    // try {
    //   if (response.statusCode == 200) {}
    // } catch (exception) {
    //   print("Call Failed: " + quranText);
    //   return quranText;
    // }

    return quranText;
  }

  Future<QuranAudio> getQuranAudio() async {
    var response = await client.get(Uri.parse(Strings.quranAudioUrl));
    var quranAudio = null;

    try {
      if (response.statusCode == 200) {
        var jsonString = response.body;
        var jsonMap = json.decode(jsonString);

        quranAudio = QuranAudio.fromJson(jsonMap);
      }
    } catch (exception) {
      print(exception);
      return quranAudio;
    }

    return quranAudio;
  }

  //Shehzad
  List<Qari> qarilist = [];

  Future<List<Qari>> getQariList() async {
    final url = "https://quranicaudio.com/api/qaris";
    final res = await http.get(Uri.parse(url));

    jsonDecode(res.body).forEach((element) {
      if (qarilist.length <
          20) // 20 is not mandatory , you can change it upto 157
        qarilist.add(Qari.fromjson(element));
    });
    qarilist.sort(
      (a, b) => a.name!.compareTo(b.name!),
    ); // sort according to A B C
    return qarilist;
  }

  final endPointUrl = "http://api.alquran.cloud/v1/surah";
  List<surah.Surah> list = [];

  Future<List<surah.Surah>> getSurah() async {
    var res = await http.get(Uri.parse(endPointUrl));
    if (res.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(res.body);
      json['data'].forEach((element) {
        if (list.length < 114) {
          list.add(surah.Surah.fromJson(element));
        }
      });
      print('ol ${list.length}');
      return list;
    } else {
      throw ("Can't get the Surah");
    }
  }

  static Future<List<dynamic>> fetchSurahList() async {
    final resp = await http.get(
      Uri.parse('https://api.alquran.cloud/v1/surah'),
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body)['data'];
    } else {
      throw Exception("Failed to load Surah list");
    }
  }

  static Future<List<String>> fetchSurahUthmani(int surahNumber) async {
    final resp = await http.get(
      Uri.parse(
        'https://api.alquran.cloud/v1/surah/$surahNumber/quran-uthmani',
      ),
    );
    if (resp.statusCode == 200) {
      final verses = jsonDecode(resp.body)['data']['ayahs'] as List;
      return verses.map((v) => v['text'] as String).toList();
    } else {
      throw Exception("Failed to load surah");
    }
  }
}
