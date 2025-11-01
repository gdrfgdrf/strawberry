import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:shared/lyric/lyric_parser.dart';

void main() async {
  final lyricsJson = {
    "sgc": false,
    "sfy": false,
    "qfy": false,
    "transUser": {
      "id": 1918039,
      "status": 99,
      "demand": 1,
      "userid": 43016512,
      "nickname": "籽猫",
      "uptime": 1454380493912
    },
    "lyricUser": {
      "id": 1918025,
      "status": 99,
      "demand": 0,
      "userid": 43016512,
      "nickname": "籽猫",
      "uptime": 1454380493912
    },
    "lrc": {
      "version": 17,
      "lyric": "[00:43.89]针を爱でる意味を授けた\n[00:45.96]仆のコトバ\n[00:48.24]赤く光る哀れみの束\n[00:50.39]缲り返して连なる\n[00:52.67]伤痕はもう惯れっこさ\n[00:55.96]灯る焦燥\n[00:58.82]\n[01:01.52]きれいごとを重ね芽生えた\n[01:03.28]淡い调和/\n[01:05.73]谁も彼も底に落とした\n[01:07.59]歪む意図\n[01:10.25]おびえ隠しあう真実/\n[01:13.44]そこに放る\n[01:16.05]描いたウソ\n[01:19.80]\n[01:20.27]また滴った\n[01:26.68]ただ愿った\n[01:34.90]まだ、/\n[01:36.01]\n[01:36.27]満たされぬ安堵 境界は皆无\n[01:40.72]こぼれおちた指から漂う感伤\n[01:44.91]そこにある残された现実\n[01:49.36]巻き戻す\n[01:50.58]変わらない日々へ\n[02:02.68]\n[02:10.83]ハリボテの槛に闭じ込めた黒い獣\n[02:15.61]耳を覆い造り笑って\n[02:17.52]模る爱想はもう\n[02:19.79]はじけ飞んで腐り落ちる\n[02:23.13]残された 狂気の涡\n[02:28.97]\n[02:29.29]暗い、未来永劫、変わらない\n[02:33.59]このまま安らかに\n[02:37.11]ああ、报い、痛い\n[02:40.01]今日も自らに负わせた声は忏悔\n[02:50.39]\n[03:38.44]これがすべて仆の写した愿い\n[03:41.73]「调和」\n[03:42.84]谁も彼も意味を失くして\n[03:44.77]渗む意図\n[03:47.32]踏み歩く屍の\n[03:50.43]そこにあった/\n[03:53.09]歪んだ\n[03:57.00]\n[03:57.32]また滴った\n[04:03.83]ただ愿った\n[04:11.20]まだ、/\n[04:12.90]\n[04:13.36]満たされぬ安堵 境界は皆无\n[04:17.80]こぼれおちた首から漂う感伤\n[04:22.08]そこにある残された现実\n[04:26.58]巻き戻す\n[04:27.57]変わらない日々へ\n"
    },
    "klyric": {
      "version": 0,
      "lyric": ""
    },
    "tlyric": {
      "version": 5,
      "lyric": "[00:43.89]/授予爱惜针筒的意义  \n[00:45.96]/我的话语\n[00:48.24]/散发腥赤光辉悲哀的束缚  \n[00:50.39]/反覆轮回不断连锁\n[00:52.67]/早已习惯伤痕的存在了啊  \n[00:55.96]/暗燃焦躁\n[00:58.82]\n[01:01.52]/积累美好之事萌芽而生  \n[01:03.28]淡薄的和谐\n[01:05.73]/无论谁人他人皆落入深渊之底  \n[01:07.59]/歪扭的意图\n[01:10.25]恐惧隐藏起的真实\n[01:13.44]/就置於一方\n[01:16.05]/过往描绘的 谎言\n[01:19.80]\n[01:20.27]/再次垂落而下\n[01:26.68]/不过是渴求愿望\n[01:34.90]尚未实现、\n[01:36.01]\n[01:36.27]/无以满足难以心安 境界线皆无\n[01:40.72]/凋零断落的指尖飘散着感伤\n[01:44.91]/此处尚残存的现实、\n[01:49.36]/倒带回转    \n[01:50.58]/回复毫无改变的每一日\n[02:02.68]\n[02:10.83]/禁闭於纸糊牢房的漆黑野兽\n[02:15.61]/掩耳造作大笑着  \n[02:17.52]/拟似的可亲外表早已\n[02:19.79]/迸裂绽飞而腐朽败落\n[02:23.13]/仅存的是 疯狂的漩涡\n[02:28.97]\n[02:29.29]/昏黑黯淡、未来永劫、不复不改\n[02:33.59]/就这麽安乐度余生\n[02:37.11]/啊啊、报应、痛苦、\n[02:40.01]/今日也得负起自作自受的语声为忏悔\n[02:50.39]\n[03:38.44]/这一切就是我写下的心愿 \n[03:41.73]/ 「和谐」\n[03:42.84]/无论谁人他人皆失去意义   \n[03:44.77]/渗漏的意图\n[03:47.32]中/踏步於具具屍首之间\n[03:50.43]确实存在彼方的\n[03:53.09]世界/歪曲的 世界\n[03:57.00]\n[03:57.32]/再次垂落而下\n[04:03.83]/不过是渴求愿望\n[04:11.20]尚未实现、\n[04:12.90]\n[04:13.36]/无以满足难以心安 境界线皆无\n[04:17.80]/凋零断落的首级飘散着感伤\n[04:22.08]/此处尚残存的现实、\n[04:26.58]/倒带回转    \n[04:27.57]/回复毫无改变的每一日"
    },
    "romalrc": {
      "version": 3,
      "lyric": "[00:43.890]ha ri wo me de ru i mi wo sa zu ke ta\n[00:45.960]bo ku no ko to ba\n[00:48.240]a ka ku hi ka ru a wa re mi no so ku\n[00:50.390]ku ri ka e shi te tsu ra na ru\n[00:52.670]ki zu a to wa mo u na re kko sa\n[00:55.960]a ka ru sho u so u\n[00:58.820]\n[01:01.520]ki re i go to wo o mo ne me ba e ta\n[01:03.280]a wa i cho u wa/\n[01:05.730]da re mo ka re mo so ko ni o to shi ta\n[01:07.590]hi zu mu i to\n[01:10.250]o bi e ka ku shi a u shi n ji tsu/\n[01:13.440]so ko ni ho u ru\n[01:16.050]e ga i ta u so\n[01:19.800]\n[01:20.270]ma ta shi zu ku tta\n[01:26.680]ta da ne ga tta\n[01:34.900]ma da、/\n[01:36.010]\n[01:36.270]mi ta sa re nu a n do kyo u ka i wa ka i mu\n[01:40.720]ko bo re o chi ta yu bi ka ra ta da yo u ka n sho u\n[01:44.910]so ko ni a ru no ko sa re ta ge n ji tsu\n[01:49.360]ma ki mo do su\n[01:50.580]ka wa ra na i hi bi e\n[02:02.680]\n[02:10.830]ha ri bo te no ra n ni to ji ko me ta ku ro i ke mo no\n[02:15.610]mi mi wo o o i tsu ku ri wa ra tte\n[02:17.520]ka ta do ru a i so u wa mo u\n[02:19.790]ha ji ke to n de ku sa ri o chi ru\n[02:23.130]no ko sa re ta kyo u ki no u zu\n[02:28.970]\n[02:29.290]ku ra i、mi ra i e i go u、ka wa ra na i\n[02:33.590]ko no ma ma ya su ra ka ni\n[02:37.110]a a、mu ku i、i ta i\n[02:40.010]kyo u mo mi zu ka ra ni o wa se ta ko e wa za n ge\n[02:50.390]\n[03:38.440]ko re ga su be te bo ku no u tsu shi ta ne ga i\n[03:41.730]「cho u wa」\n[03:42.840]da re mo ka re mo i mi wo na ku shi te\n[03:44.770]ni ji mu i to\n[03:47.320]fu mi a ru ku shi ka ba ne no\n[03:50.430]so ko ni a tta/\n[03:53.090]hi zu n da\n[03:57.000]\n[03:57.320]ma ta shi zu ku tta\n[04:03.830]ta da ne ga tta\n[04:11.200]ma da、/\n[04:12.900]\n[04:13.360]mi ta sa re nu a n do kyo u ka i wa ka i mu\n[04:17.800]ko bo re o chi ta ku bi ka ra ta da yo u ka n sho u\n[04:22.080]so ko ni a ru no ko sa re ta ge n ji tsu\n[04:26.580]ma ki mo do su\n[04:27.570]ka wa ra na i hi bi e"
    },
    "yrc": {
      "version": 3,
      "lyric": "[ch:0]\n[43800,2060](43800,580,0)针(44380,30,0)を(44410,110,0)爱(44520,120,0)で(44640,130,0)る(44770,120,0)意(44890,200,0)味(45090,90,0)を(45180,310,0)授(45490,140,0)け(45630,230,0)た\n[45860,2180](45860,760,0)仆(46620,570,0)の(47190,200,0)コ(47390,370,0)ト(47760,280,0)バ\n[48260,1940](48260,340,0)赤(48600,140,0)く(48740,280,0)光(49020,160,0)る(49180,240,0)哀(49420,130,0)れ(49550,130,0)み(49680,140,0)の(49820,380,0)束\n[50200,2220](50200,160,0)缲(50360,270,0)り(50630,360,0)返(50990,230,0)し(51220,270,0)て(51490,420,0)连(51910,270,0)な(52180,240,0)る\n[52630,3060](52630,470,0)伤(53100,300,0)痕(53400,330,0)は(53730,140,0)も(53870,410,0)う(54280,360,0)惯(54640,130,0)れ(54770,400,0)っ(55170,160,0)こ(55330,360,0)さ\n[55960,2920](55960,600,0)灯(56560,170,0)る(56730,750,0)焦(57480,1400,0)燥\n[61310,2050](61310,270,0)き(61580,60,0)れ(61640,220,0)い(61860,140,0)ご(62000,100,0)と(62100,130,0)を(62230,270,0)重(62500,130,0)ね(62630,150,0)芽(62780,200,0)生(62980,90,0)え(63070,290,0)た\n[63390,2390](63390,830,0)淡(64220,370,0)い(64590,710,0)调(65300,260,0)和(65560,220,0)/\n[65780,1860](65780,300,0)谁(66080,130,0)も(66210,260,0)彼(66470,110,0)も(66580,290,0)底(66870,150,0)に(67020,120,0)落(67140,150,0)と(67290,140,0)し(67430,210,0)た\n[67640,2190](67640,640,0)歪(68280,1070,0)む(69350,30,0)意(69380,450,0)図\n[70110,3200](70110,170,0)お(70280,230,0)び(70510,150,0)え(70660,430,0)隠(71090,470,0)し(71560,270,0)あ(71830,140,0)う(71970,610,0)真(72580,570,0)実(73150,160,0)/\n[73310,2180](73310,380,0)そ(73690,330,0)こ(74020,240,0)に(74260,800,0)放(75060,430,0)る\n[76050,4110](76050,610,0)描(76660,850,0)い(77510,770,0)た(78280,140,0)ウ(78420,1740,0)ソ\n[80190,6020](80190,390,0)ま(80580,1670,0)た(82250,750,0)滴(83000,280,0)っ(83280,2930,0)た\n[86740,6660](86740,130,0)た(86870,4150,0)だ(91020,700,0)愿(91720,290,0)っ(92010,1390,0)た\n[93900,2450](93900,816,0)ま(94716,816,0)だ(95532,818,0)、/\n[96350,4070](96350,110,0)満(96460,130,0)た(96590,330,0)さ(96920,80,0)れ(97000,1030,0)ぬ(98030,60,0)安(98090,110,0)堵 (98200,430,0)境(98630,440,0)界(99070,480,0)は(99550,580,0)皆(100130,290,0)无\n[100690,4050](100690,170,0)こ(100860,160,0)ぼ(101020,220,0)れ(101240,230,0)お(101470,370,0)ち(101840,210,0)た(102050,550,0)指(102600,190,0)か(102790,230,0)ら(103020,730,0)漂(103750,120,0)う(103870,340,0)感(104210,530,0)伤\n[104910,4240](104910,280,0)そ(105190,130,0)こ(105320,310,0)に(105630,160,0)あ(105790,330,0)る(106120,480,0)残(106600,390,0)さ(106990,1370,0)れ(108360,80,0)た(108440,160,0)现(108600,550,0)実\n[109390,1040](109390,100,0)巻(109490,170,0)き(109660,470,0)戻(110130,300,0)す\n[110470,11760](110470,260,0)変(110730,330,0)わ(111060,190,0)ら(111250,260,0)な(111510,590,0)い(112100,170,0)日(112270,60,0)々(112330,9900,0)へ\n[131050,4280](131050,300,0)ハ(131350,130,0)リ(131480,140,0)ボ(131620,160,0)テ(131780,200,0)の(131980,220,0)槛(132200,120,0)に(132320,130,0)闭(132450,160,0)じ(132610,130,0)込(132740,130,0)め(132870,240,0)た(133110,730,0)黒(133840,650,0)い(134490,840,0)獣\n[135570,1940](135570,420,0)耳(135990,130,0)を(136120,140,0)覆(136260,210,0)い(136470,280,0)造(136750,120,0)り(136870,370,0)笑(137240,50,0)っ(137290,220,0)て\n[137970,1810](137970,80,0)模(138050,210,0)る(138260,450,0)爱(138710,350,0)想(139060,70,0)は(139130,570,0)も(139700,80,0)う\n[139900,3120](139900,200,0)は(140100,150,0)じ(140250,250,0)け(140500,470,0)飞(140970,110,0)ん(141080,180,0)で(141260,630,0)腐(141890,270,0)り(142160,200,0)落(142360,340,0)ち(142700,320,0)る\n[143180,5720](143180,510,0)残(143690,280,0)さ(143970,890,0)れ(144860,930,0)た (145790,920,0)狂(146710,560,0)気(147270,1080,0)の(148350,550,0)涡\n[149150,4270](149150,490,0)暗(149640,490,0)い(150130,190,0)、(150320,310,0)未(150630,470,0)来(151100,630,0)永(151730,310,0)劫(152040,170,0)、(152210,330,0)変(152540,300,0)わ(152840,230,0)ら(153070,90,0)な(153160,260,0)い\n[153590,3510](153590,240,0)こ(153830,350,0)の(154180,110,0)ま(154290,310,0)ま(154600,670,0)安(155270,710,0)ら(155980,640,0)か(156620,480,0)に\n[157100,2720](157100,420,0)あ(157520,430,0)あ(157950,0,0)、(157950,540,0)报(158490,340,0)い(158830,400,0)、(159230,490,0)痛(159720,100,0)い\n[159820,58710](159820,160,0)今(159980,450,0)日(160430,470,0)も(160900,890,0)自(161790,130,0)ら(161920,400,0)に(162320,260,0)负(162580,200,0)わ(162780,210,0)せ(162990,390,0)た(163380,550,0)声(163930,53080,0)は(217010,1430,0)忏(218440,90,0)悔\n[218530,3180](218530,70,0)こ(218600,210,0)れ(218810,60,0)が(218870,190,0)す(219060,130,0)べ(219190,120,0)て(219310,370,0)仆(219680,70,0)の(219750,280,0)写(220030,150,0)し(220180,160,0)た(220340,860,0)愿(221200,510,0)い\n[221710,1150](221710,0,0)「(221710,640,0)调(222350,250,0)和(222600,260,0)」\n[222860,2200](222860,320,0)谁(223180,120,0)も(223300,270,0)彼(223570,120,0)も(223690,140,0)意(223830,170,0)味(224000,30,0)を(224030,200,0)失(224230,170,0)く(224400,130,0)し(224530,530,0)て\n[225090,1770](225090,300,0)渗(225390,1050,0)む(226440,30,0)意(226470,390,0)図\n[227160,2830](227160,210,0)踏(227370,240,0)み(227610,440,0)歩(228050,180,0)く(228230,1220,0)屍(229450,540,0)の\n[230400,3750](230400,380,0)そ(230780,2180,0)こ(232960,70,0)に(233030,280,0)あ(233310,200,0)っ(233510,390,0)た(233900,250,0)/\n[234150,780](234150,260,0)歪(234410,260,0)ん(234670,260,0)だ\n[235760,12410](235760,80,0)ま(235840,3450,0)た(239290,780,0)滴(240070,240,0)っ(240310,7860,0)た\n[248400,2390](248400,478,0)た(248878,478,0)だ(249356,478,0)愿(249834,478,0)っ(250312,478,0)た\n[250820,2650](250820,883,0)ま(251703,883,0)だ(252586,884,0)、/\n[253470,4240](253470,60,0)満(253530,110,0)た(253640,340,0)さ(253980,70,0)れ(254050,480,0)ぬ(254530,680,0)安(255210,430,0)堵 (255640,60,0)境(255700,430,0)界(256130,430,0)は(256560,670,0)皆(257230,480,0)无\n[257740,4130](257740,317,0)こ(258057,317,0)ぼ(258374,317,0)れ(258691,317,0)お(259008,317,0)ち(259325,317,0)た(259642,317,0)首(259959,317,0)か(260276,317,0)ら(260593,317,0)漂(260910,317,0)う(261227,317,0)感(261544,326,0)伤\n[262080,4310](262080,200,0)そ(262280,140,0)こ(262420,280,0)に(262700,200,0)あ(262900,290,0)る(263190,550,0)残(263740,310,0)さ(264050,410,0)れ(264460,390,0)た(264850,780,0)现(265630,760,0)実\n[266390,1130](266390,240,0)巻(266630,130,0)き(266760,480,0)戻(267240,280,0)す\n[267550,12630](267550,1578,0)変(269128,1578,0)わ(270706,1578,0)ら(272284,1578,0)な(273862,1578,0)い(275440,1578,0)日(277018,1578,0)々(278596,1584,0)へ\n"
    },
    "code": 200,
    "roles": []
  };
  final lyrics = LyricParser.parse(jsonEncode(lyricsJson));
  final combined = lyrics.combine()!;

  for (final combination in combined) {
    print(
      "${combination.text} | ${combination.translatedText} | ${combination.romanText} | ${combination.position} | ${combination.wordBasedLyric?.text} | ${combination.wordBasedLyric?.position} | ${combination.wordBasedLyric?.duration}",
    );
  }

  final positionStream = StreamController<Duration>();
  final scheduler = LyricScheduler(combined, positionStream.stream);
  scheduler.ignoreNullStandardText = true;
  scheduler.start();

  int currentPosition = 0;
  scheduler.lyricStream.listen((data) {
    if (data == null) {
      return;
    }
    final lyric = data.lyric;

    if (data is WordBasedLyricStreamData) {
      if (lyric is CombinedLyric) {
        print(
          "[$currentPosition ms] Combined - 行: ${data.index} | 文本: ${lyric.wordBasedLyric?.text} | 当前字: ${data.wordInfo?.word}",
        );
      }
      if (lyric is WordBasedLyric) {
        print(
          '[$currentPosition ms] 逐字歌词 - 行: ${data.index} | 文本: ${lyric.text} | 当前字: ${data.wordInfo?.word}',
        );
      }
      return;
    }

    if (lyric is JsonLyric) {
      print(
        '[$currentPosition ms] Json - 行: ${data.index} | 文本: ${lyric.texts.join()}',
      );
    }
    if (lyric is StandardLyric) {
      print(
        '[$currentPosition ms] 标准歌词 - 行: ${data.index} | 文本: ${lyric.text}',
      );
    }
    if (lyric is CombinedLyric) {
      print(
        '[$currentPosition ms] Combined - 行: ${data.index} | 文本: ${lyric.text}',
      );
    }
  });

  positionStream.add(Duration(milliseconds: 0));
  final timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
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
  final List<CombinedLyric> _lyrics;
  final Stream<Duration> positionStream;
  bool ignoreNullStandardText = false;

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
    final lyricDatas = _findCurrentLyric(position);
    if (lyricDatas != null) {
      for (final lyricData in lyricDatas) {
        lyricStream.add(lyricData);
      }
    }
  }

  List<LyricStreamData>? _findCurrentLyric(Duration position) {
    final effectiveLyrics = _getEffectiveLyrics();
    if (effectiveLyrics.isEmpty) {
      return null;
    }

    final currentLines = _findCurrentLine(position, effectiveLyrics);
    if (currentLines == null) {
      _currentLyricIndex = -1;
      _currentWordInfo = null;
      return null;
    }

    final results = <LyricStreamData>[];
    for (final currentLine in currentLines) {
      final currentIndex = currentLine.$1;
      final currentUnit = currentLine.$2;

      WordInfo? currentWordInfo;
      if (currentUnit.wordBasedLyric != null) {
        currentWordInfo = _findCurrentWord(
          position,
          currentUnit.wordBasedLyric!,
        );
      }

      if (currentIndex == _currentLyricIndex &&
          currentWordInfo == _currentWordInfo) {
        continue;
      }

      _currentLyricIndex = currentIndex;
      _currentWordInfo = currentWordInfo;

      if (currentUnit.wordBasedLyric != null && currentWordInfo != null) {
        results.add(
          WordBasedLyricStreamData(
            currentIndex,
            currentUnit,
            wordInfo: currentWordInfo,
          ),
        );
        continue;
      }

      results.add(LyricStreamData(currentIndex, currentUnit));
    }

    return results;
  }

  List<(int, CombinedLyric)> _getEffectiveLyrics() {
    final result = <(int, CombinedLyric)>[];
    for (int i = 0; i < _lyrics.length; i++) {
      final unit = _lyrics[i];
      result.add((i, unit));
    }
    return result;
  }

  List<(int, CombinedLyric)>? _findCurrentLine(
    Duration position,
    List<(int, CombinedLyric)> effectiveLyrics,
  ) {
    final results = <(int, CombinedLyric)>[];

    for (int i = 0; i < effectiveLyrics.length; i++) {
      final previous = i <= 0 ? null : effectiveLyrics[i - 1];
      final current = effectiveLyrics[i];
      final next =
          i + 1 < effectiveLyrics.length ? effectiveLyrics[i + 1] : null;

      final previousUnit = previous?.$2;
      final currentUnit = current.$2;
      final nextUnit = next?.$2;

      if (currentUnit.wordBasedLyric == null) {
        if (currentUnit.text == null && ignoreNullStandardText) {
          continue;
        }

        if (nextUnit != null) {
          if (position >= currentUnit.position &&
              position <= nextUnit.position) {
            results.add(current);
          }
        }
      } else {
        if (previousUnit != null && previousUnit.wordBasedLyric == null) {
          final currentPosition = currentUnit.wordBasedLyric!.position;

          if (currentPosition <= previousUnit.position) {
            final endTime1 =
                currentUnit.position + currentUnit.wordBasedLyric!.duration;
            final endTime2 =
                currentUnit.wordBasedLyric!.position +
                currentUnit.wordBasedLyric!.duration;
            final endTime = Duration(
              milliseconds: min(
                endTime1.inMilliseconds,
                endTime2.inMilliseconds,
              ),
            );

            if (position >= currentUnit.position && position <= endTime) {
              results.add(current);
            }

            continue;
          }
        }

        final endTime =
            currentUnit.wordBasedLyric!.position +
            currentUnit.wordBasedLyric!.duration;

        if (currentUnit.wordBasedLyric != null) {
          if (position > currentUnit.wordBasedLyric!.position &&
              position < endTime) {
            results.add(current);
          }
        }
      }
    }
    if (results.isNotEmpty) {
      return results;
    }

    if (effectiveLyrics.isNotEmpty) {
      final last = effectiveLyrics.last;
      final lastUnit = last.$2;
      if (position >= lastUnit.position) {
        return [last];
      }
    }

    return null;
  }

  WordInfo? _findCurrentWord(Duration position, WordBasedLyric lyricLine) {
    if (lyricLine.wordInfos == null) {
      return null;
    }

    for (final wordInfo in lyricLine.wordInfos!) {
      final wordEndPosition = wordInfo.position + wordInfo.duration;

      if (position >= wordInfo.position && position <= wordEndPosition) {
        return wordInfo;
      }
    }

    final lineEndTime = lyricLine.position + lyricLine.duration;
    if (position >= lyricLine.position &&
        position < lineEndTime &&
        lyricLine.wordInfos!.isNotEmpty) {
      return lyricLine.wordInfos!.last;
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
