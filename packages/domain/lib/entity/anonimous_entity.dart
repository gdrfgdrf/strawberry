
import 'dart:convert';

class AnonimousEntity {
  final int userId;
  final int createTime;

  const AnonimousEntity(this.userId, this.createTime);

  static AnonimousEntity parseJson(String string) {
    final json = jsonDecode(string);
    return AnonimousEntity(json["userId"] ?? -1, json["createTime"] ?? -1);
  }
}