import 'package:domain/entity/song_entity.dart';
import 'package:domain/entity/song_file_entity.dart';
import 'package:domain/entity/song_quality_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:smooth_list_view/smooth_list_view.dart';

class SongFileChip {
  static SongFileChip vip = SongFileChip("FILE VIP", (songFile) {
    return songFile.flags.contains(SongFlag.vipSong);
  });
  static SongFileChip trial = SongFileChip("FILE TRIAL", (songFile) {
    if (songFile.freeTrialInfo != null) {
      return true;
    }
    return songFile.flags.contains(SongFlag.freeTrial);
  });
  static SongFileChip qualityStd = SongFileChip("FILE STD", (songFile) {
    return songFile.level == SongQualityLevel.standard;
  });
  static SongFileChip qualityHigher = SongFileChip("FILE HIGHER", (songFile) {
    return songFile.level == SongQualityLevel.higher;
  });
  static SongFileChip qualityExhigh = SongFileChip("FILE EXHIGH", (songFile) {
    return songFile.level == SongQualityLevel.exhigh;
  });
  static SongFileChip qualityLossless = SongFileChip("FILE LOSSLESS", (songFile) {
    return songFile.level == SongQualityLevel.lossless;
  });
  static SongFileChip qualityHires = SongFileChip("FILE HIRES", (songFile) {
    return songFile.level == SongQualityLevel.hires;
  });
  static SongFileChip qualityJyeffect = SongFileChip("FILE JYEFFECT", (songFile) {
    return songFile.level == SongQualityLevel.jyeffect;
  });
  static SongFileChip qualitySky = SongFileChip("FILE SKY", (songFile) {
    return songFile.level == SongQualityLevel.sky;
  });
  static SongFileChip qualityDolby = SongFileChip("FILE DOLBY", (songFile) {
    return songFile.level == SongQualityLevel.dolby;
  });
  static SongFileChip qualityJymaster = SongFileChip("FILE JYMASTER", (songFile) {
    return songFile.level == SongQualityLevel.jymaster;
  });
  static List<SongFileChip> values = [
    vip,
    trial,
    qualityStd,
    qualityHigher,
    qualityExhigh,
    qualityLossless,
    qualityHires,
    qualityJyeffect,
    qualitySky,
    qualityDolby,
    qualityJymaster
  ];

  final String text;
  final bool Function(SongFileEntity) detector;

  const SongFileChip(this.text, this.detector);
}

class SongChip {
  static SongChip vip = SongChip("VIP", (song) {
    return song.purchase == SongPurchaseType.onlyVip;
  });
  static SongChip cloud = SongChip("CLOUD", (song) {
    return song.cloudMusicInfo != null;
  });
  static List<SongChip> values = [vip, cloud];

  final String text;
  final bool Function(SongEntity) detector;

  const SongChip(this.text, this.detector);
}

class SongChips extends StatelessWidget {
  final SongEntity song;
  final SongFileEntity songFile;
  final bool reverse;

  const SongChips({super.key, required this.song, required this.songFile, this.reverse = false});

  Widget buildChip(String text) {
    return Material(
      color: Colors.transparent,
      child: SmoothContainer(
        side: BorderSide(
          width: 2,
          color: themeData().colorScheme.outlineVariant,
        ),
        alignment: Alignment.center,
        borderRadius: BorderRadius.circular(4),
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text(text, style: TextStyle(fontSize: 8.sp)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chipString = <String>[];
    for (final chip in SongChip.values) {
      if (chip.detector(song)) {
        chipString.add(chip.text);
      }
    }
    for (final chip in SongFileChip.values) {
      if (chip.detector(songFile)) {
        chipString.add(chip.text);
      }
    }

    return SmoothListView.builder(
      scrollDirection: Axis.horizontal,
      duration: Duration(milliseconds: 500),
      physics: BouncingScrollPhysics(),
      reverse: reverse,
      itemCount: chipString.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: 4),
          child: buildChip(chipString[index]),
        );
      },
    );
  }
}
