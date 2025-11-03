class DuaModel {
  String? id;
  String? dua;
  String? translation;
  String? reference;
  List<String>? audios;

  DuaModel({this.id, this.dua, this.translation, this.reference, this.audios});

  DuaModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dua = json['dua'];
    translation = json['translation'];
    reference = json['reference'];
    audios = json['audios'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['dua'] = this.dua;
    data['translation'] = this.translation;
    data['reference'] = this.reference;
    data['audios'] = this.audios;
    return data;
  }
}
