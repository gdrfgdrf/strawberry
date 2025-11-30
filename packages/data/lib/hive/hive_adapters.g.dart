// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class CacheHitAdapter extends TypeAdapter<CacheHit> {
  @override
  final typeId = 0;

  @override
  CacheHit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheHit(fields[3] as String, (fields[2] as num).toInt());
  }

  @override
  void write(BinaryWriter writer, CacheHit obj) {
    writer
      ..writeByte(2)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.sentence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheHitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SongCombinationAdapter extends TypeAdapter<SongCombination> {
  @override
  final typeId = 1;

  @override
  SongCombination read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongCombination(
      fields[0] as SongEntity,
      fields[1] as SongPrivilegeEntity,
    );
  }

  @override
  void write(BinaryWriter writer, SongCombination obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.song)
      ..writeByte(1)
      ..write(obj.privilege);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongCombinationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SongEntityAdapter extends TypeAdapter<SongEntity> {
  @override
  final typeId = 2;

  @override
  SongEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongEntity(
      (fields[0] as num).toInt(),
      fields[1] as String,
      fields[2] as String?,
      fields[3] as String?,
      fields[4] as Duration,
      fields[5] as BasicAlbumEntity?,
      fields[6] as bool,
      (fields[7] as List).cast<String>(),
      (fields[8] as List).cast<String>(),
      (fields[9] as List).cast<ArtistEntity>(),
      fields[10] as SongSingType,
      fields[12] as SongPurchaseType,
      fields[18] as bool,
      fields[19] as String?,
      (fields[20] as num).toInt(),
      (fields[21] as num).toInt(),
      (fields[22] as num).toInt(),
      fields[23] as SongMatchType,
      (fields[24] as List).cast<MarkType>(),
      (fields[25] as num).toInt(),
      fields[26] as CloudMusicInfo?,
      (fields[27] as num).toDouble(),
      (fields[28] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, SongEntity obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.mainTitle)
      ..writeByte(3)
      ..write(obj.additionalTitle)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.basicAlbum)
      ..writeByte(6)
      ..write(obj.owned)
      ..writeByte(7)
      ..write(obj.sources)
      ..writeByte(8)
      ..write(obj.localizedNames)
      ..writeByte(9)
      ..write(obj.artists)
      ..writeByte(10)
      ..write(obj.singType)
      ..writeByte(12)
      ..write(obj.purchase)
      ..writeByte(18)
      ..write(obj.hasCopyright)
      ..writeByte(19)
      ..write(obj.cdOrder)
      ..writeByte(20)
      ..write(obj.order)
      ..writeByte(21)
      ..write(obj.djId)
      ..writeByte(22)
      ..write(obj.mvId)
      ..writeByte(23)
      ..write(obj.match)
      ..writeByte(24)
      ..write(obj.marks)
      ..writeByte(25)
      ..write(obj.relation)
      ..writeByte(26)
      ..write(obj.cloudMusicInfo)
      ..writeByte(27)
      ..write(obj.popular)
      ..writeByte(28)
      ..write(obj.publishTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BasicAlbumEntityAdapter extends TypeAdapter<BasicAlbumEntity> {
  @override
  final typeId = 3;

  @override
  BasicAlbumEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BasicAlbumEntity(
      (fields[0] as num).toInt(),
      fields[1] as String,
      fields[2] as String,
      (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, BasicAlbumEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.picUrl)
      ..writeByte(3)
      ..write(obj.localizedNames);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BasicAlbumEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ArtistEntityAdapter extends TypeAdapter<ArtistEntity> {
  @override
  final typeId = 4;

  @override
  ArtistEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArtistEntity(
      (fields[0] as num).toInt(),
      (fields[1] as num?)?.toInt(),
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      (fields[6] as num).toInt(),
      (fields[7] as num).toInt(),
      (fields[8] as num).toInt(),
      fields[9] as bool,
      (fields[10] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ArtistEntity obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.accountId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.backgroundUrl)
      ..writeByte(5)
      ..write(obj.avatarUrl)
      ..writeByte(6)
      ..write(obj.albumCount)
      ..writeByte(7)
      ..write(obj.musicCount)
      ..writeByte(8)
      ..write(obj.musicVideo)
      ..writeByte(9)
      ..write(obj.followed)
      ..writeByte(10)
      ..write(obj.alias);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SongSingTypeAdapter extends TypeAdapter<SongSingType> {
  @override
  final typeId = 5;

  @override
  SongSingType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SongSingType.unknown;
      case 1:
        return SongSingType.original;
      case 2:
        return SongSingType.cover;
      default:
        return SongSingType.unknown;
    }
  }

  @override
  void write(BinaryWriter writer, SongSingType obj) {
    switch (obj) {
      case SongSingType.unknown:
        writer.writeByte(0);
      case SongSingType.original:
        writer.writeByte(1);
      case SongSingType.cover:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongSingTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SongOriginBasicDataAdapter extends TypeAdapter<SongOriginBasicData> {
  @override
  final typeId = 6;

  @override
  SongOriginBasicData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongOriginBasicData(
      (fields[0] as num).toInt(),
      fields[1] as String,
      (fields[2] as List).cast<ArtistEntity>(),
      fields[3] as BasicAlbumEntity,
    );
  }

  @override
  void write(BinaryWriter writer, SongOriginBasicData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.artists)
      ..writeByte(3)
      ..write(obj.basicAlbum);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongOriginBasicDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SongPurchaseTypeAdapter extends TypeAdapter<SongPurchaseType> {
  @override
  final typeId = 7;

  @override
  SongPurchaseType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SongPurchaseType.freeOrNoCopyright;
      case 1:
        return SongPurchaseType.onlyVip;
      case 2:
        return SongPurchaseType.albumPurchase;
      case 3:
        return SongPurchaseType.vipHigh;
      default:
        return SongPurchaseType.freeOrNoCopyright;
    }
  }

  @override
  void write(BinaryWriter writer, SongPurchaseType obj) {
    switch (obj) {
      case SongPurchaseType.freeOrNoCopyright:
        writer.writeByte(0);
      case SongPurchaseType.onlyVip:
        writer.writeByte(1);
      case SongPurchaseType.albumPurchase:
        writer.writeByte(2);
      case SongPurchaseType.vipHigh:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongPurchaseTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SongQualityEntityAdapter extends TypeAdapter<SongQualityEntity> {
  @override
  final typeId = 8;

  @override
  SongQualityEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongQualityEntity(
      (fields[0] as num).toInt(),
      (fields[1] as num).toInt(),
      (fields[2] as num).toInt(),
      (fields[3] as num).toDouble(),
      (fields[4] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, SongQualityEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.br)
      ..writeByte(1)
      ..write(obj.fid)
      ..writeByte(2)
      ..write(obj.size)
      ..writeByte(3)
      ..write(obj.volumeDelta)
      ..writeByte(4)
      ..write(obj.sr);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongQualityEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SongMatchTypeAdapter extends TypeAdapter<SongMatchType> {
  @override
  final typeId = 9;

  @override
  SongMatchType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SongMatchType.normal;
      case 1:
        return SongMatchType.cloudIndependent;
      case 2:
        return SongMatchType.cloudNonIndependent;
      default:
        return SongMatchType.normal;
    }
  }

  @override
  void write(BinaryWriter writer, SongMatchType obj) {
    switch (obj) {
      case SongMatchType.normal:
        writer.writeByte(0);
      case SongMatchType.cloudIndependent:
        writer.writeByte(1);
      case SongMatchType.cloudNonIndependent:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongMatchTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MarkTypeAdapter extends TypeAdapter<MarkType> {
  @override
  final typeId = 10;

  @override
  MarkType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MarkType.stereo;
      case 1:
        return MarkType.pure;
      case 2:
        return MarkType.dolby;
      case 3:
        return MarkType.explicit;
      case 4:
        return MarkType.hires;
      case 5:
        return MarkType.unknown;
      default:
        return MarkType.stereo;
    }
  }

  @override
  void write(BinaryWriter writer, MarkType obj) {
    switch (obj) {
      case MarkType.stereo:
        writer.writeByte(0);
      case MarkType.pure:
        writer.writeByte(1);
      case MarkType.dolby:
        writer.writeByte(2);
      case MarkType.explicit:
        writer.writeByte(3);
      case MarkType.hires:
        writer.writeByte(4);
      case MarkType.unknown:
        writer.writeByte(5);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CloudMusicInfoAdapter extends TypeAdapter<CloudMusicInfo> {
  @override
  final typeId = 11;

  @override
  CloudMusicInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CloudMusicInfo(
      (fields[0] as num).toInt(),
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      (fields[6] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, CloudMusicInfo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.coverId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.filename)
      ..writeByte(4)
      ..write(obj.songName)
      ..writeByte(5)
      ..write(obj.artist)
      ..writeByte(6)
      ..write(obj.bitrate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudMusicInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SongPrivilegeEntityAdapter extends TypeAdapter<SongPrivilegeEntity> {
  @override
  final typeId = 12;

  @override
  SongPrivilegeEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongPrivilegeEntity(
      (fields[0] as num).toInt(),
      fields[1] as SongPurchaseType,
      (fields[2] as num).toInt(),
      fields[3] as bool,
      fields[4] as bool,
      (fields[5] as num).toInt(),
      fields[6] as SongQualityLevel,
      (fields[7] as num).toInt(),
      fields[8] as SongQualityLevel,
      (fields[9] as num).toInt(),
      fields[10] as SongQualityLevel,
      fields[11] as SongQualityLevel,
      fields[12] as SongQualityLevel,
      fields[13] as SongQualityLevel,
      fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SongPrivilegeEntity obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.purchase)
      ..writeByte(2)
      ..write(obj.purchased)
      ..writeByte(3)
      ..write(obj.available)
      ..writeByte(4)
      ..write(obj.cloudMusic)
      ..writeByte(5)
      ..write(obj.maxBitrate)
      ..writeByte(6)
      ..write(obj.maxBitrateLevel)
      ..writeByte(7)
      ..write(obj.playMaxBitrate)
      ..writeByte(8)
      ..write(obj.playMaxBitrateLevel)
      ..writeByte(9)
      ..write(obj.downloadMaxBitrate)
      ..writeByte(10)
      ..write(obj.downloadMaxBitrateLevel)
      ..writeByte(11)
      ..write(obj.freeQuality)
      ..writeByte(12)
      ..write(obj.downloadQuality)
      ..writeByte(13)
      ..write(obj.playQuality)
      ..writeByte(14)
      ..write(obj.toast);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongPrivilegeEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SongQualityLevelAdapter extends TypeAdapter<SongQualityLevel> {
  @override
  final typeId = 13;

  @override
  SongQualityLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SongQualityLevel.standard;
      case 1:
        return SongQualityLevel.higher;
      case 2:
        return SongQualityLevel.exhigh;
      case 3:
        return SongQualityLevel.lossless;
      case 4:
        return SongQualityLevel.hires;
      case 5:
        return SongQualityLevel.jyeffect;
      case 6:
        return SongQualityLevel.sky;
      case 7:
        return SongQualityLevel.dolby;
      case 8:
        return SongQualityLevel.jymaster;
      case 9:
        return SongQualityLevel.none;
      default:
        return SongQualityLevel.standard;
    }
  }

  @override
  void write(BinaryWriter writer, SongQualityLevel obj) {
    switch (obj) {
      case SongQualityLevel.standard:
        writer.writeByte(0);
      case SongQualityLevel.higher:
        writer.writeByte(1);
      case SongQualityLevel.exhigh:
        writer.writeByte(2);
      case SongQualityLevel.lossless:
        writer.writeByte(3);
      case SongQualityLevel.hires:
        writer.writeByte(4);
      case SongQualityLevel.jyeffect:
        writer.writeByte(5);
      case SongQualityLevel.sky:
        writer.writeByte(6);
      case SongQualityLevel.dolby:
        writer.writeByte(7);
      case SongQualityLevel.jymaster:
        writer.writeByte(8);
      case SongQualityLevel.none:
        writer.writeByte(9);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongQualityLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoginResultAdapter extends TypeAdapter<LoginResult> {
  @override
  final typeId = 14;

  @override
  LoginResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginResult(fields[0] as Account, fields[1] as Profile);
  }

  @override
  void write(BinaryWriter writer, LoginResult obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.account)
      ..writeByte(1)
      ..write(obj.profile);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final typeId = 15;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      (fields[0] as num).toInt(),
      fields[1] as String,
      (fields[2] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.createTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final typeId = 16;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      (fields[0] as num).toInt(),
      fields[1] as String,
      fields[2] as String,
      (fields[3] as num).toInt(),
      fields[4] as Gender,
      fields[5] as Province,
      fields[6] as City,
      fields[7] as String,
      fields[8] as String,
      fields[9] as bool,
      fields[10] as bool,
      (fields[11] as num?)?.toInt(),
      (fields[12] as num?)?.toInt(),
      (fields[13] as num?)?.toInt(),
      fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.signature)
      ..writeByte(3)
      ..write(obj.birthday)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.province)
      ..writeByte(6)
      ..write(obj.city)
      ..writeByte(7)
      ..write(obj.avatarUrl)
      ..writeByte(8)
      ..write(obj.backgroundUrl)
      ..writeByte(9)
      ..write(obj.defaultAvatar)
      ..writeByte(10)
      ..write(obj.followed)
      ..writeByte(11)
      ..write(obj.fanCount)
      ..writeByte(12)
      ..write(obj.followCount)
      ..writeByte(13)
      ..write(obj.eventCount)
      ..writeByte(14)
      ..write(obj.followTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GenderAdapter extends TypeAdapter<Gender> {
  @override
  final typeId = 17;

  @override
  Gender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gender.undefined;
      case 1:
        return Gender.male;
      case 2:
        return Gender.female;
      default:
        return Gender.undefined;
    }
  }

  @override
  void write(BinaryWriter writer, Gender obj) {
    switch (obj) {
      case Gender.undefined:
        writer.writeByte(0);
      case Gender.male:
        writer.writeByte(1);
      case Gender.female:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProvinceAdapter extends TypeAdapter<Province> {
  @override
  final typeId = 18;

  @override
  Province read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Province(
      (fields[0] as num).toInt(),
      fields[1] as String,
      (fields[3] as List).cast<City>(),
      alias: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Province obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.alias)
      ..writeByte(3)
      ..write(obj.cities);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProvinceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CityAdapter extends TypeAdapter<City> {
  @override
  final typeId = 19;

  @override
  City read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return City((fields[0] as num).toInt(), fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, City obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CacheInfoAdapter extends TypeAdapter<CacheInfo> {
  @override
  final typeId = 20;

  @override
  CacheInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheInfo(
      fields[0] as String,
      fields[1] as String,
      (fields[2] as num).toInt(),
      fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CacheInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.tag)
      ..writeByte(1)
      ..write(obj.filename)
      ..writeByte(2)
      ..write(obj.accessCount)
      ..writeByte(3)
      ..write(obj.extension);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserHabitAdapter extends TypeAdapter<UserHabit> {
  @override
  final typeId = 21;

  @override
  UserHabit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserHabit(fields[0] as String, fields[1] as String?);
  }

  @override
  void write(BinaryWriter writer, UserHabit obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserHabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SongFileEntityAdapter extends TypeAdapter<SongFileEntity> {
  @override
  final typeId = 22;

  @override
  SongFileEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongFileEntity(
      (fields[0] as num).toInt(),
      fields[1] as String?,
      fields[2] as String,
      fields[3] as String,
      (fields[4] as num).toInt(),
      fields[5] as SongQualityLevel,
      (fields[6] as List).cast<SongFlag>(),
      (fields[7] as num).toInt(),
      (fields[8] as num).toInt(),
      (fields[9] as num).toDouble(),
      (fields[10] as num).toDouble(),
      (fields[11] as num).toDouble(),
      (fields[12] as num).toDouble(),
      fields[13] as String,
      fields[14] as Duration,
      fields[15] as FreeTrialInfo?,
      fields[16] as SongPurchaseType,
      (fields[17] as num).toInt(),
      fields[18] as Duration,
    );
  }

  @override
  void write(BinaryWriter writer, SongFileEntity obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.encodeType)
      ..writeByte(4)
      ..write(obj.size)
      ..writeByte(5)
      ..write(obj.level)
      ..writeByte(6)
      ..write(obj.flags)
      ..writeByte(7)
      ..write(obj.rawFlag)
      ..writeByte(8)
      ..write(obj.bitrate)
      ..writeByte(9)
      ..write(obj.volumeDelta)
      ..writeByte(10)
      ..write(obj.peak)
      ..writeByte(11)
      ..write(obj.closedVolumeDelta)
      ..writeByte(12)
      ..write(obj.closedPeak)
      ..writeByte(13)
      ..write(obj.md5)
      ..writeByte(14)
      ..write(obj.expireAfter)
      ..writeByte(15)
      ..write(obj.freeTrialInfo)
      ..writeByte(16)
      ..write(obj.purchase)
      ..writeByte(17)
      ..write(obj.purchased)
      ..writeByte(18)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongFileEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SongFlagAdapter extends TypeAdapter<SongFlag> {
  @override
  final typeId = 23;

  @override
  SongFlag read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SongFlag.noCopyright;
      case 1:
        return SongFlag.copyrighted;
      case 2:
        return SongFlag.freeTrial;
      case 3:
        return SongFlag.exclusive;
      case 4:
        return SongFlag.vipSong;
      case 5:
        return SongFlag.albumPurchase;
      case 6:
        return SongFlag.official;
      case 7:
        return SongFlag.nonOfficial;
      case 8:
        return SongFlag.highQuality;
      default:
        return SongFlag.noCopyright;
    }
  }

  @override
  void write(BinaryWriter writer, SongFlag obj) {
    switch (obj) {
      case SongFlag.noCopyright:
        writer.writeByte(0);
      case SongFlag.copyrighted:
        writer.writeByte(1);
      case SongFlag.freeTrial:
        writer.writeByte(2);
      case SongFlag.exclusive:
        writer.writeByte(3);
      case SongFlag.vipSong:
        writer.writeByte(4);
      case SongFlag.albumPurchase:
        writer.writeByte(5);
      case SongFlag.official:
        writer.writeByte(6);
      case SongFlag.nonOfficial:
        writer.writeByte(7);
      case SongFlag.highQuality:
        writer.writeByte(8);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongFlagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FreeTrialInfoAdapter extends TypeAdapter<FreeTrialInfo> {
  @override
  final typeId = 24;

  @override
  FreeTrialInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FreeTrialInfo(
      (fields[0] as num).toInt(),
      (fields[1] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, FreeTrialInfo obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreeTrialInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoreLyricAdapter extends TypeAdapter<StoreLyric> {
  @override
  final typeId = 25;

  @override
  StoreLyric read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreLyric(fields[0] as Duration, fields[1] as String?);
  }

  @override
  void write(BinaryWriter writer, StoreLyric obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.position)
      ..writeByte(1)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreLyricAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoreWordInfoAdapter extends TypeAdapter<StoreWordInfo> {
  @override
  final typeId = 26;

  @override
  StoreWordInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreWordInfo(
      fields[0] as String,
      fields[1] as Duration,
      fields[2] as Duration,
    );
  }

  @override
  void write(BinaryWriter writer, StoreWordInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.position)
      ..writeByte(2)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreWordInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoreWordBasedLyricAdapter extends TypeAdapter<StoreWordBasedLyric> {
  @override
  final typeId = 27;

  @override
  StoreWordBasedLyric read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreWordBasedLyric(
      fields[0] as Duration,
      fields[1] as Duration,
      fields[2] as String?,
      (fields[3] as List?)?.cast<StoreWordInfo>(),
    );
  }

  @override
  void write(BinaryWriter writer, StoreWordBasedLyric obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.position)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.wordInfos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreWordBasedLyricAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoreStandardLyricsAdapter extends TypeAdapter<StoreStandardLyrics> {
  @override
  final typeId = 28;

  @override
  StoreStandardLyrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreStandardLyrics(
      (fields[0] as List).cast<StoreLyric>(),
      (fields[1] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, StoreStandardLyrics obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lyrics)
      ..writeByte(1)
      ..write(obj.ignoration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreStandardLyricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoreTranslatedLyricsAdapter extends TypeAdapter<StoreTranslatedLyrics> {
  @override
  final typeId = 29;

  @override
  StoreTranslatedLyrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreTranslatedLyrics(
      (fields[0] as List?)?.cast<StoreLyric>(),
      (fields[1] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, StoreTranslatedLyrics obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lyrics)
      ..writeByte(1)
      ..write(obj.ignoration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreTranslatedLyricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoreRomanLyricsAdapter extends TypeAdapter<StoreRomanLyrics> {
  @override
  final typeId = 30;

  @override
  StoreRomanLyrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreRomanLyrics(
      (fields[0] as List?)?.cast<StoreLyric>(),
      (fields[1] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, StoreRomanLyrics obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lyrics)
      ..writeByte(1)
      ..write(obj.ignoration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreRomanLyricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoreWordBasedLyricsAdapter extends TypeAdapter<StoreWordBasedLyrics> {
  @override
  final typeId = 31;

  @override
  StoreWordBasedLyrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreWordBasedLyrics(
      (fields[0] as List?)?.cast<StoreWordBasedLyric>(),
      (fields[1] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, StoreWordBasedLyrics obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lyrics)
      ..writeByte(1)
      ..write(obj.ignoration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreWordBasedLyricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoreLyricsAdapter extends TypeAdapter<StoreLyrics> {
  @override
  final typeId = 32;

  @override
  StoreLyrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreLyrics(
      fields[0] as StoreStandardLyrics,
      fields[1] as StoreTranslatedLyrics,
      fields[2] as StoreRomanLyrics,
      fields[5] as StoreWordBasedLyrics?,
      (fields[4] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, StoreLyrics obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.standardLyrics)
      ..writeByte(1)
      ..write(obj.translatedLyrics)
      ..writeByte(2)
      ..write(obj.romanLyrics)
      ..writeByte(4)
      ..write(obj.roleCounts)
      ..writeByte(5)
      ..write(obj.wordBasedLyrics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreLyricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
