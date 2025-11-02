// To parse this JSON data, do
//
//     final quranAudio = quranAudioFromJson(jsonString);

import 'dart:convert';

QuranAudio quranAudioFromJson(String str) =>
    QuranAudio.fromJson(json.decode(str));

String quranAudioToJson(QuranAudio data) => json.encode(data.toJson());

class QuranAudio {
  QuranAudio({this.code, this.status, this.data});

  int? code;
  String? status;
  List<Datum>? data;

  factory QuranAudio.fromJson(Map<String, dynamic> json) => QuranAudio(
    code: json["code"],
    status: json["status"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "status": status,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    this.identifier,
    this.language,
    this.name,
    this.englishName,
    this.format,
    this.type,
    this.direction,
  });

  String? identifier;
  String? language;
  String? name;
  String? englishName;
  Format? format;
  Type? type;
  dynamic direction;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    identifier: json["identifier"],
    language: json["language"],
    name: json["name"],
    englishName: json["englishName"],
    format: formatValues.map![json["format"]],
    type: typeValues.map![json["type"]],
    direction: json["direction"],
  );

  Map<String, dynamic> toJson() => {
    "identifier": identifier,
    "language": language,
    "name": name,
    "englishName": englishName,
    "format": formatValues.reverse![format],
    "type": typeValues.reverse![type],
    "direction": direction,
  };
}

enum Format { AUDIO }

final formatValues = EnumValues({"audio": Format.AUDIO});

enum Type { TRANSLATION, VERSEBYVERSE }

final typeValues = EnumValues({
  "translation": Type.TRANSLATION,
  "versebyverse": Type.VERSEBYVERSE,
});

class EnumValues<T> {
  Map<String, T>? map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    if (reverseMap == null) {
      reverseMap = map!.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
