import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared/lyric/lyric_parser.dart';

void main() async {
  // final lyricsString =
  //     "{\"t\":0,\"c\":[{\"tx\":\"作词: \"},{\"tx\":\"STELLA\"}]}\n{\"t\":10315,\"c\":[{\"tx\":\"作曲: \"},{\"tx\":\"STELLA\"}]}\n[20630,5210](20630,180,0)あ(20810,160,0)な(20970,150,0)た(21120,270,0)も(21390,440,0)き(21830,100,0)っ(21930,450,0)と(22430,230,0)そ(22660,410,0)う(23070,140,0)で(23210,110,0)し(23320,360,0)ょ(23680,1340,0)う\n[25840,5190](25840,330,0)足(26170,330,0)早(26500,180,0)に(26680,260,0)通(26940,220,0)り(27160,110,0)過(27270,360,0)ぎ(27630,130,0)て(27760,230,0)い(28170,310,0)く(28480,1600,0)風\n[31030,5200](31030,340,0)隠(31370,160,0)し(31530,170,0)き(31700,180,0)れ(31880,400,0)な(32280,50,0)い(32330,280,0)不(32610,400,0)安(33010,330,0)や(33370,560,0)寂(33930,370,0)し(34650,880,0)さ\n[36230,5090](36230,380,0)誰(36610,160,0)か(36770,260,0)に(37030,50,0)打(37080,420,0)ち(37500,230,0)明(37730,330,0)け(38060,420,0)た(38480,210,0)い(38690,210,0)け(38900,1220,0)ど\n[41320,5240](41320,530,0)心(41850,300,0)配(42150,490,0)事(42640,280,0)は(42920,430,0)き(43350,120,0)っ(43470,380,0)と(43920,180,0)あ(44100,260,0)る(44360,250,0)で(45270,230,0)し(45500,160,0)ょ(45660,740,0)う\n[46560,5350](46560,720,0)瞳(47280,100,0)を(47380,130,0)閉(47510,180,0)じ(47690,160,0)て(47850,170,0)も(48020,350,0)消(48370,130,0)え(48500,270,0)な(48770,280,0)い(49050,340,0)記(49390,1130,0)憶\n[51910,4550](51910,120,0)ど(52030,200,0)う(52230,220,0)し(52450,80,0)よ(52530,60,0)う(52590,170,0)も(52760,310,0)な(53070,230,0)く(53300,400,0)溢(53700,190,0)れ(53890,310,0)る(54270,2090,0)涙\n[56460,5890](56460,370,0)誰(56830,160,0)か(56990,640,0)に(57680,290,0)ぬ(57970,300,0)ぐ(58270,50,0)っ(58320,430,0)て(59050,200,0)欲(59250,120,0)し(59370,220,0)い(59590,170,0)け(59760,1980,0)ど\n[62350,10430](62350,1190,0)誰(63720,60,0)も(63780,50,0)い(63830,400,0)な(64230,330,0)い(64560,260,0)ん(64820,260,0)で(65080,380,0)す (67560,1400,0)私(69050,660,0)以(69710,1840,0)外\n[72780,9810](72780,820,0)誰(73630,510,0)も(74140,130,0)い(74270,390,0)な(74660,330,0)い(74990,270,0)ん(75260,250,0)で(75510,380,0)す (78010,190,0)あ(78200,610,0)な(78810,860,0)た(79670,490,0)以(80160,700,0)外\n[82590,6340](82590,470,0)そ(83060,40,0)っ(83100,410,0)と(83950,430,0)深(84380,520,0)く(85170,420,0)息(85590,510,0)を(86520,380,0)吐(86900,100,0)い(87000,520,0)て (87800,470,0)そ(88270,40,0)っ(88310,390,0)と\n[88930,5390](88930,340,0)そ(89270,180,0)の(89450,780,0)心(90230,550,0)に(91010,410,0)隠(91420,140,0)し(91560,160,0)た(91720,710,0)塊(92430,80,0)を(92510,350,0)全(92860,170,0)て(93030,130,0)出(93160,200,0)し(93360,550,0)て\n[94320,7170](94320,480,0)そ(94800,40,0)っ(94840,420,0)と(95700,420,0)深(96120,460,0)く(96930,390,0)息(97320,530,0)を(98370,260,0)吐(98630,100,0)い(98730,520,0)て (99540,240,0)そ(99780,1450,0)う\n[101490,13000](101490,140,0)出(101630,350,0)し(101980,190,0)た(102170,490,0)分(102660,140,0)だ(102800,460,0)け(103300,350,0)吸(103650,160,0)え(103810,150,0)る(103960,1800,0)か(109140,1250,0)ら\n[114490,5240](114490,210,0)こ(114700,170,0)こ(114870,170,0)で(115040,140,0)生(115180,190,0)き(115370,310,0)る(115680,180,0)の(115860,540,0)は(117030,970,0)辛(118000,80,0)い(118330,100,0)で(118430,110,0)し(118540,180,0)ょ(118720,370,0)う\n[119730,5260](119730,180,0)途(119910,260,0)絶(120170,120,0)え(120290,130,0)る(120420,160,0)こ(120580,290,0)と(120870,250,0)の(121120,510,0)な(121630,170,0)い(121800,1130,0)争(122930,750,0)い\n[124990,5170](124990,180,0)生(125170,130,0)ま(125300,160,0)れ(125460,330,0)続(125790,300,0)け(126090,160,0)る(126250,520,0)妬(126770,190,0)み(126960,370,0)や(127400,1000,0)恨(128400,330,0)み(128730,440,0)の(129200,770,0)渦\n[130160,5140](130160,200,0)止(130360,150,0)ま(130510,170,0)る(130680,180,0)こ(130860,190,0)と(131050,120,0)は(131170,240,0)な(131410,110,0)い(131520,500,0)と(132060,270,0)分(132330,290,0)か(132620,40,0)っ(132660,130,0)て(132790,330,0)る(133120,180,0)け(133300,680,0)ど\n[135300,5220](135300,940,0)何(136240,370,0)も(136610,660,0)な(137270,330,0)い(137600,260,0)ん(137860,260,0)で(138120,980,0)す\n[140520,5210](140520,910,0)守(141430,40,0)っ(141470,350,0)て(141820,300,0)く(142120,340,0)れ(142460,260,0)る(142720,360,0)も(143080,650,0)の(143730,1440,0)も\n[145730,4520](145730,940,0)何(146670,380,0)も(147050,660,0)な(147710,330,0)い(148040,250,0)ん(148290,260,0)で(148550,380,0)す\n[150250,3290](150250,640,0)幸(150890,220,0)せ　(151110,440,0)を(151640,210,0)保(151850,330,0)証(152180,180,0)す(152360,330,0)る(152690,180,0)も(152870,170,0)の(153040,470,0)も\n[153540,2180](153540,540,0)何(154080,410,0)ひ(154490,300,0)と(154790,260,0)つ\n[155720,6260](155720,410,0)そ(156130,50,0)っ(156180,410,0)と(157010,450,0)深(157460,510,0)く(158240,410,0)息(158650,510,0)を(159670,300,0)吐(159970,90,0)い(160060,530,0)て (160830,490,0)そ(161320,50,0)っ(161370,380,0)と\n[161980,3270](161980,330,0)そ(162310,130,0)の(162440,850,0)瞳(163290,550,0)に(164130,130,0)溜(164260,200,0)め(164460,150,0)た(164610,160,0)ま(164770,160,0)ま(164930,320,0)の\n[165250,2040](165250,185,0)涙(165435,185,0)を(165620,185,0)号(165805,185,0)ん(165990,185,0)で(166175,185,0)（(166360,185,0)さ(166545,185,0)け(166730,185,0)ん(166915,185,0)で(167100,190,0)）\n[167290,7120](167290,560,0)そ(167850,40,0)っ(167890,440,0)と(168690,470,0)深(169160,460,0)く(169980,390,0)息(170370,510,0)を(171270,480,0)吸(171750,30,0)っ(171780,510,0)て (172580,250,0)そ(172830,1550,0)う\n[174410,23680](174410,370,0)吐(174780,240,0)い(175020,190,0)た(175210,500,0)分(175710,140,0)だ(175850,450,0)け(176340,380,0)吸(176720,100,0)え(176820,180,0)る(177000,4450,0)か(189360,60,0)ら\n[198090,5270](198090,830,0)We (198920,600,0)are (200110,500,0)just (200610,1050,0)human (201700,1260,0)beings\n[203360,4840](203360,780,0)We (204140,310,0)are (204450,280,0)all (205730,700,0)weak (206430,500,0)and (206960,1190,0)timid\n[208200,1850](208200,410,0)But (208610,870,0)we(209480,0,0)”(209480,60,0)re\n[210050,4420](210050,780,0)Still (210870,1090,0)breathing (211960,320,0)on (212280,490,0)our (214000,300,0)own\n[214470,4560](214470,470,0)You (214940,200,0)are (215140,390,0)not (215530,1910,0)alone(217440,880,0).(218320,310,0)Never\n[219030,4410](219030,490,0)深(219520,490,0)く(220010,490,0)息(220500,490,0)を(221480,490,0)吐(221970,490,0)い(222460,490,0)て\n[223440,1110](223440,490,0)そ(223930,40,0)っ(223970,380,0)と\n[224550,5430](224550,380,0)そ(224930,130,0)の(225060,410,0)震(225470,390,0)え(225860,610,0)た(226540,340,0)背(226880,330,0)中(227210,240,0)に(227450,80,0)あ(227530,300,0)る(227830,580,0)翼(228410,70,0)を(228480,500,0)広(228980,190,0)げ(229170,500,0)て\n[229980,6940](229980,470,0)す(230450,50,0)っ(230500,480,0)と(231370,400,0)深(231770,530,0)く(232570,410,0)息(232980,850,0)を(233860,500,0)吸(234360,40,0)っ(234400,570,0)て　(235200,230,0)そ(235430,1230,0)う\n[236920,2800](236920,300,0)き(237220,120,0)っ(237340,280,0)と(237620,490,0)高(238110,320,0)く(238430,170,0)飛(238600,330,0)べ(238930,370,0)る(239300,290,0)か(239590,130,0)ら\n[239720,4700](239720,361,0)も(240081,361,0)う(240442,361,0)後(240803,361,0)ろ(241164,361,0)は(241886,361,0)振(242247,361,0)り(242608,361,0)向(242969,361,0)か(243330,361,0)な(243691,361,0)い(244052,368,0)で\n[244420,5570](244420,260,0)ど(244680,30,0)ん(244710,460,0)な(245200,60,0)恐(245260,60,0)怖(245320,60,0)も(246330,350,0)悲(246680,360,0)し(247040,390,0)み(247470,80,0)も(247550,170,0)振(247720,320,0)り(248040,380,0)切(248420,300,0)れ(248720,160,0)る\n[249990,4620](249990,330,0)だ(250320,360,0)か(250680,280,0)ら(251020,140,0)ギ(251160,160,0)ュ(251320,50,0)ッ(251370,210,0)と(251580,270,0)こ(252160,330,0)の(252490,210,0)手(252700,200,0)を(252900,970,0)握(253870,100,0)っ(253970,90,0)て\n[254610,4580](254610,654,0)羽(255264,654,0)ば(255918,654,0)た(257226,654,0)こ(257880,654,0)う\n[259190,125270](259190,20878,0)To (280068,20878,0)the (300946,20878,0)future (321824,20878,0)you (342702,20878,0)want\n";
  final lyricsString = "{\"t\":0,\"c\":[{\"tx\":\"作词: \"},{\"tx\":\"STELLA\"}]}\n{\"t\":1000,\"c\":[{\"tx\":\"作曲: \"},{\"tx\":\"STELLA\"}]}\n[00:19:84]あなたもきっとそうでしょう\n[00:24:67]足早に通り過ぎていく風\n[00:30:41]隠しきれない不安や寂しさ\n[00:35:46]誰かに打ち明けたいけど\n[00:40:71]心配事はきっとあるでしょう\n[00:46:15]瞳を閉じても消えない記憶\n[00:51:05]どうしようもなく溢れる涙\n[00:56:09]誰かにぬぐって欲しいけど\n[01:01:67]誰もいないんです 私以外\n[01:11:61]誰もいないんです あなた以外\n[01:22:22]そっと深く息を吐いて そっと\n[01:28:33]その心に隠した塊を全て出して\n[01:33:41]そっと深く息を吐いて そう\n[01:40:65]出した分だけ吸えるから\n[01:53:41]ここで生きるのは辛いでしょう\n[01:58:88]途絶えることのない争い\n[02:03:87]生まれ続ける妬みや恨みの渦\n[02:09:61]止まることはないと分かってるけど\n[02:14:94]何もないんです\n[02:19:20]守ってくれるものも\n[02:25:04]何もないんです\n[02:29:69]幸せ　を保証するものも\n[02:33:11]何ひとつ\n[02:35:40]そっと深く息を吐いて そっと\n[02:41:38]その瞳に溜めたままの\n[02:44:93]涙を号んで(さけんで)\n[02:46:73]そっと深く息を吸って そう\n[02:53:71]吐いた分だけ吸えるから\n[03:16:89]We are just human beings\n[03:22:67]We are all weak and timid\n[03:27:89]But we”re\n[03:29:67]Still breathing on our own\n[03:33:68]You are not alone.Never\n[03:39:00]深く息を吐いて\n[03:43:12]そっと\n[03:44:04]その震えた背中にある翼を広げて\n[03:49:34]すっと深く息を吸って　そう\n[03:56:48]きっと高く飛べるから\n[03:59:83]もう後ろは振り向かないで\n[04:04:10]どんな恐怖も悲しみも振り切れる\n[04:09:31]だからギュッとこの手を握って\n[04:14:43]羽ばたこう\n[04:18:83]To the future you want\n";
  final lyrics = LyricParser.parse(lyricsString);

  for (final lyric in lyrics) {
    if (lyric is JsonLyric) {
      print("${lyric.position} | ${lyric.texts}");
    }
    if (lyric is CombinedRawLyric) {
      print('${lyric.position} | ${lyric.text}');
    }
    if (lyric is CombinedWordBasedLyric) {
      print('${lyric.position} | ${lyric.duration} | ${lyric.text}');
    }
  }

  final positionStream = StreamController<Duration>();
  final scheduler = LyricScheduler(lyrics, positionStream.stream);
  scheduler.start();

  int currentPosition = 0;
  Timer? timer;

  scheduler.lyricStream.listen((data) {
    if (data != null) {
      final lyric = data.lyric;

      if (lyric is JsonLyric) {
        print('[$currentPosition ms] Json - 行: ${data.index} | 文本: ${lyric.texts.join()}');
      }
      if (lyric is CombinedRawLyric) {
        print(
          '[$currentPosition ms] 标准歌词 - 行: ${data.index} | 文本: ${lyric.text}',
        );
      }
      if (data is WordBasedLyricStreamData) {
        if (lyric is CombinedWordBasedLyric) {
          print(
            '[$currentPosition ms] 逐字歌词 - 行: ${data.index} | 文本: ${lyric.text} | 当前字: ${data.wordInfo?.word}',
          );
        }
      }
    }
  });

  positionStream.add(Duration(milliseconds: 0));
  timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
    currentPosition += 50;
    positionStream.add(Duration(milliseconds: currentPosition));
  });
  await Future.delayed(const Duration(minutes: 10));
  timer.cancel();
  positionStream.close();
  scheduler.dispose();
}

class LyricStreamData {
  final int index;
  final LyricUnit lyric;

  LyricStreamData(this.index, this.lyric);
}

class WordBasedLyricStreamData extends LyricStreamData {
  final WordInfo? wordInfo;

  WordBasedLyricStreamData(super.index, super.lyric, {this.wordInfo});
}

class LyricScheduler {
  final List<LyricUnit> _lyrics;
  final Stream<Duration> positionStream;

  final BehaviorSubject<LyricStreamData?> lyricStream = BehaviorSubject.seeded(
    null,
  );

  StreamSubscription? _positionSubscription;
  int _currentLyricIndex = -1;
  WordInfo? _currentWordInfo;

  LyricScheduler(this._lyrics, this.positionStream);

  void start() {
    _positionSubscription = positionStream.listen(_handlePositionUpdate);
  }

  void stop() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _handlePositionUpdate(Duration position) {
    final lyricData = _findCurrentLyric(position);
    lyricStream.add(lyricData);
  }

  LyricStreamData? _findCurrentLyric(Duration position) {
    final effectiveLyrics = _getEffectiveLyrics();
    if (effectiveLyrics.isEmpty) {
      return null;
    }

    final currentLine = _findCurrentLine(position, effectiveLyrics);
    if (currentLine == null) {
      _currentLyricIndex = -1;
      _currentWordInfo = null;
      return null;
    }

    final currentIndex = currentLine.$1;
    final currentUnit = currentLine.$2;

    WordInfo? currentWordInfo;
    if (currentUnit is CombinedWordBasedLyric) {
      currentWordInfo = _findCurrentWord(position, currentUnit);
    }

    if (currentIndex == _currentLyricIndex &&
        currentWordInfo == _currentWordInfo) {
      return null;
    }

    _currentLyricIndex = currentIndex;
    _currentWordInfo = currentWordInfo;

    if (currentUnit is CombinedWordBasedLyric && currentWordInfo != null) {
      return WordBasedLyricStreamData(
        currentIndex,
        currentUnit,
        wordInfo: currentWordInfo,
      );
    } else {
      return LyricStreamData(currentIndex, currentUnit);
    }
  }

  List<(int, LyricUnit)> _getEffectiveLyrics() {
    final result = <(int, LyricUnit)>[];
    for (int i = 0; i < _lyrics.length; i++) {
      final unit = _lyrics[i];
      if (unit is JsonLyric ||
          unit is CombinedRawLyric ||
          unit is CombinedWordBasedLyric) {
        result.add((i, unit));
      }
    }
    return result;
  }

  (int, LyricUnit)? _findCurrentLine(
    Duration position,
    List<(int, LyricUnit)> effectiveLyrics,
  ) {
    for (int i = 0; i < effectiveLyrics.length; i++) {
      final current = effectiveLyrics[i];
      final next =
          i + 1 < effectiveLyrics.length ? effectiveLyrics[i + 1] : null;

      final currentUnit = current.$2;
      final nextUnit = next?.$2;

      Duration? endTime;
      if (currentUnit is JsonLyric || currentUnit is CombinedRawLyric) {
        if (nextUnit != null) {
          endTime = nextUnit.position;
        } else {
          endTime = null;
        }
      }
      if (currentUnit is CombinedWordBasedLyric) {
        endTime = currentUnit.position + currentUnit.duration;
      }

      if (endTime == null) {
        return effectiveLyrics.last;
      }
      if (position >= currentUnit.position && position < endTime) {
        return current;
      }
    }

    if (effectiveLyrics.isNotEmpty) {
      final last = effectiveLyrics.last;
      final lastUnit = last.$2;
      if (position >= lastUnit.position) {
        return last;
      }
    }

    return null;
  }

  WordInfo? _findCurrentWord(
    Duration position,
    CombinedWordBasedLyric lyricLine,
  ) {
    for (final wordInfo in lyricLine.wordInfos) {
      final wordEndTime = wordInfo.position + wordInfo.duration;

      if (position >= wordInfo.position && position < wordEndTime) {
        return wordInfo;
      }
    }

    final lineEndTime = lyricLine.position + lyricLine.duration;
    if (position >= lyricLine.position &&
        position < lineEndTime &&
        lyricLine.wordInfos.isNotEmpty) {
      return lyricLine.wordInfos.last;
    }

    return null;
  }

  void seekTo(Duration position) {
    _currentLyricIndex = -1;
    _currentWordInfo = null;
    _handlePositionUpdate(position);
  }

  void dispose() {
    stop();
    lyricStream.close();
  }
}
