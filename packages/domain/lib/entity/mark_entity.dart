
import 'package:hive_ce/hive.dart';
import 'package:domain/hives.dart';

/// 给定一数字 a，计算 a & num，若结果 == num，说明拥有该 mark
@HiveType(typeId: HiveTypes.markId)
enum MarkType {
  /// 立体声
  @HiveField(0)
  stereo(8192),
  /// 纯音乐
  @HiveField(1)
  pure(131072),
  @HiveField(2)
  dolby(262144),
  @HiveField(3)
  explicit(1048576),
  @HiveField(4)
  hires(17179869184),
  @HiveField(5)
  unknown(-1),
  ;

  final int num;

  const MarkType(this.num);

  static MarkType parseNum(int num) {
    switch (num) {
      case 8192: return MarkType.stereo;
      case 131072: return MarkType.pure;
      case 262144: return MarkType.dolby;
      case 1048576: return MarkType.explicit;
      case 17179869184: return MarkType.hires;
      default: return MarkType.unknown;
    }
  }

  static List<MarkType> calculate(int mark) {
    List<MarkType> result = [];

    for (final type in MarkType.values) {
      if (type == MarkType.unknown) {
        continue;
      }

      final num = type.num;
      if (mark & num == num) {
        result.add(type);
      }
    }

    return result;
  }
}