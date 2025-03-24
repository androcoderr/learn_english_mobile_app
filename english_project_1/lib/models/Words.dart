import 'dart:convert';

Words wordsFromJson(String str) {
  final jsonData = json.decode(str);
  return Words.fromJson(jsonData);
}

String wordsToJson(Words data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Words {
  int id;
  int categoryId;
  String eng;
  String tr;

  Words({
    required this.id,
    required this.categoryId,
    required this.eng,
    required this.tr,
  });

  factory Words.fromJson(Map<String, dynamic> json) => new Words(
    id: json["id"],
    categoryId: json["categoryId"],
    eng: json["ENG"],
    tr: json["TR"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "categoryId": categoryId,
    "ENG": eng,
    "TR": tr,
  };
}