import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:domain/entity/region_parser.dart';
import 'package:domain/hives.dart';

@HiveType(typeId: HiveTypes.genderId)
enum Gender {
  @HiveField(0)
  undefined,
  @HiveField(1)
  male,
  @HiveField(2)
  female;

  static Gender get(int i) {
    switch (i) {
      case 0:
        {
          return undefined;
        }
      case 1:
        {
          return male;
        }
      case 2:
        {
          return female;
        }
    }
    throw ArgumentError("unknown gender, maybe you are an armed helicopter?");
  }
}

@HiveType(typeId: HiveTypes.accountId)
class Account {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String userName;
  @HiveField(2)
  final int createTime;

  const Account(this.id, this.userName, this.createTime);

  static Account parseJson(String string) {
    final json = jsonDecode(string);

    return Account(
      json["id"] ?? -1,
      json["userName"] ?? "undefined",
      json["createTime"] ?? -1,
    );
  }
}

@HiveType(typeId: HiveTypes.profileId)
class Profile {
  @HiveField(0)
  final int userId;
  @HiveField(1)
  final String nickname;
  @HiveField(2)
  final String signature;
  @HiveField(3)
  final int birthday;
  @HiveField(4)
  final Gender gender;
  @HiveField(5)
  final Province province;
  @HiveField(6)
  final City city;
  @HiveField(7)
  final String avatarUrl;
  @HiveField(8)
  final String backgroundUrl;
  @HiveField(9)
  final bool defaultAvatar;

  @HiveField(10)
  final bool followed;

  @HiveField(11)
  final int? fanCount;
  @HiveField(12)
  final int? followCount;
  @HiveField(13)
  final int? eventCount;
  @HiveField(14)
  final String? followTime;

  const Profile(
    this.userId,
    this.nickname,
    this.signature,
    this.birthday,
    this.gender,
    this.province,
    this.city,
    this.avatarUrl,
    this.backgroundUrl,
    this.defaultAvatar,
    this.followed,
    this.fanCount,
    this.followCount,
    this.eventCount,
    this.followTime,
  );

  static Profile parseJson(String string) {
    final json = jsonDecode(string);

    return Profile(
      json["userId"] ?? -1,
      json["nickname"] ?? "undefined",
      json["signature"] ?? "undefined",
      json["birthday"] ?? -1,
      Gender.get(json["gender"] ?? 0),
      RegionParser.findProvince(json["province"] ?? 110000),
      RegionParser.findCity(
        json["province"] ?? 110000,
        json["city"] ?? 110101,
      ),
      json["avatarUrl"] ?? "undefined",
      json["backgroundUrl"] ?? "undefined",
      json["defaultAvatar"] ?? true,
      json["followed"] ?? false,
      json["followeds"] ?? -1,
      json["follows"] ?? -1,
      json["eventCount"] ?? -1,
      json["followTime"] ?? "",
    );
  }

  static Profile parseJson_Type1(String string) {
    final json = jsonDecode(string);

    return Profile(
      json["userId"] ?? -1,
      json["nickname"] ?? "undefined",
      json["signature"] ?? "undefined",
      json["birthday"] - 1,
      Gender.get(json["gender"] ?? 0),
      RegionParser.findProvince(json["province"] ?? 110000),
      RegionParser.findCity(
        json["province"] ?? 110000,
        json["city"] ?? 110101,
      )!,
      json["avatarUrl"] ?? "undefined",
      json["backgroundUrl"] ?? "undefined",
      json["defaultAvatar"] ?? true,
      json["followMe"] ?? false,
      json["followeds"] ?? -1,
      json["follows"] ?? -1,
      json["eventCount"] ?? -1,
      json["followTime"] ?? "",
    );
  }
}
