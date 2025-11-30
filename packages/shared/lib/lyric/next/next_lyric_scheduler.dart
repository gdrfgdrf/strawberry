import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared/lyric/lyric_parser.dart';
import 'package:shared/lyric/next/next_word_based_lyric_corrector.dart';

class ChunkedWordInfo {
  final Duration begin;
  final Duration? end;
  final WordInfo wordInfo;

  const ChunkedWordInfo(this.begin, this.end, this.wordInfo);

  bool contains(Duration position) {
    if (end == null) {
      return position >= begin;
    }
    return position >= begin && position < end!;
  }
}

class ChunkedLyric {
  final Duration begin;
  final Duration? end;
  final CombinedLyric lyric;

  const ChunkedLyric(this.begin, this.end, this.lyric);

  bool contains(Duration position) {
    if (end == null) {
      return position >= begin;
    }
    return position >= begin && position < end!;
  }
}

class LyricChunker {
  static List<ChunkedWordInfo> makeWordInfos(List<WordInfo> wordInfos) {
    final result = <ChunkedWordInfo>[];
    for (int i = 0; i < wordInfos.length; i++) {
      final wordInfo = wordInfos[i];
      final next = i >= wordInfos.length - 1 ? null : wordInfos[i + 1];
      if (next == null) {
        result.add(
          ChunkedWordInfo(
            wordInfo.position,
            wordInfo.position + wordInfo.duration,
            wordInfo,
          ),
        );
        continue;
      }
      if (wordInfo.position + wordInfo.duration >= next.position) {
        result.add(ChunkedWordInfo(wordInfo.position, next.position, wordInfo));
        continue;
      }
      result.add(
        ChunkedWordInfo(
          wordInfo.position,
          wordInfo.position + wordInfo.duration,
          wordInfo,
        ),
      );
    }
    return result;
  }

  static List<ChunkedLyric> makeLyrics(List<CombinedLyric> combinedLyrics) {
    final result = <ChunkedLyric>[];
    for (int i = 0; i < combinedLyrics.length; i++) {
      final lyric = combinedLyrics[i];
      final next =
          i >= combinedLyrics.length - 1 ? null : combinedLyrics[i + 1];
      if (next == null) {
        result.add(ChunkedLyric(lyric.position, null, lyric));
        continue;
      }
      result.add(ChunkedLyric(lyric.position, next.position, lyric));
    }
    return result;
  }
}

class ScheduledLyric {
  final int index;
  final CombinedLyric lyric;

  const ScheduledLyric(this.index, this.lyric);
}

class NextRawLyricScheduler {
  final List<CombinedLyric> combinedLyrics;
  final Stream<Duration> positionStream;

  int? previousIndex;
  List<ChunkedLyric>? chunkedLyrics;
  BehaviorSubject<ScheduledLyric?>? lyricSubject;
  StreamSubscription? positionSubscription;

  NextRawLyricScheduler(this.combinedLyrics, this.positionStream);

  void prepare() {
    chunkedLyrics = LyricChunker.makeLyrics(combinedLyrics);
    lyricSubject = BehaviorSubject.seeded(null);
  }

  void start() {
    if (chunkedLyrics == null || chunkedLyrics?.isEmpty == true) {
      return;
    }
    if (lyricSubject == null || lyricSubject?.isClosed == true) {
      return;
    }
    positionSubscription = positionStream.listen(_onPosition);
  }

  void _onPosition(Duration position) {
    if (chunkedLyrics == null || chunkedLyrics?.isEmpty == true) {
      return;
    }
    if (lyricSubject == null || lyricSubject?.isClosed == true) {
      return;
    }
    int? index;
    ChunkedLyric? chunkedLyric;

    for (int i = 0; i < chunkedLyrics!.length; i++) {
      final chunk = chunkedLyrics![i];
      if (chunk.contains(position)) {
        chunkedLyric = chunk;
        index = i;
        break;
      }
    }
    if (index == null || chunkedLyric == null) {
      return;
    }
    if (index == previousIndex) {
      return;
    }
    previousIndex = index;

    lyricSubject!.add(ScheduledLyric(index, chunkedLyric.lyric));
  }

  void dispose() {
    combinedLyrics.clear();
    chunkedLyrics?.clear();
    chunkedLyrics = null;
    lyricSubject?.close();
    lyricSubject = null;
    positionSubscription?.cancel();
    positionSubscription = null;
  }
}

class ScheduledWordBasedLyric {
  final int index;
  final int wordIndex;
  final CombinedLyric lyric;
  final List<WordInfo> wordInfos;

  const ScheduledWordBasedLyric(
    this.index,
    this.wordIndex,
    this.lyric,
    this.wordInfos,
  );
}

// void main() {
//   final lyricsJson = {
//     "sgc": false,
//     "sfy": false,
//     "qfy": false,
//     "transUser": {
//       "id": 41324436,
//       "status": 99,
//       "demand": 1,
//       "userid": 78317886,
//       "nickname": "FinaFina",
//       "uptime": 1705066589868
//     },
//     "lrc": {
//       "version": 8,
//       "lyric": "[00:00.00] 作词 : 吉田夜世\n[00:01.00] 作曲 : 吉田夜世\n[00:02.00] 编曲 : 吉田夜世\n[00:12:08]バッドランドに生まれた\n[00:14:11]だけでバッドライフがデフォとか\n[00:16:46]くだらないけど、それが理なんだって\n[00:19:63]もう参っちゃうね\n[00:21:64]抗うために\n[00:22:66]エスケープ・フロム・デンエン\n[00:24:67]蛇のように這い、善戦\n[00:26:48]だけど最後、逆転の一手だけ\n[00:29:46]何故か詰められないの！\n[00:31:38]暗い無頼社会 vs. BRIGHT未来世界\n[00:35:35]ならちょっと後者に行ってくる\n[00:37:68]大丈夫か？うるせえよ\n[00:40:04]限界まで足掻いた人生は\n[00:42:37]想像よりも狂っているらしい\n[00:44:94]半端な生命の関数を\n[00:47:07]少々ここらでオーバーライド\n[00:49:69]…したい所だけど現実は\n[00:51:75]そうそう上手くはいかないようで\n[00:54:46]吐いた言葉だけが信条だって\n[00:57:12]思われてまた離れ離れ\n[01:08:53]まぁ、この世の中ガチャの引き次第で\n[01:11:22]何もかも説明つくわけだし？\n[01:13:62]巻き返しに必要な力で\n[01:16:03]別の事頑張ればいいじゃん(笑)\n[01:18:03]まぁ、この地獄の沙汰も金次第で\n[01:20:73]どこまでも左右出来るわけだし？\n[01:23:10]アンタが抜け出せるわけがないよ(笑)\n[01:25:39]それで話はおしまい？\n[01:26:95]ならば もう こないからねー\n[01:29:43]豪快さにかまけた人生は\n[01:31:74]きっと燃やされてしまうらしい\n[01:34:34]じゃあワタシなど要らないと\n[01:36:48]蹴った果てにいた付和雷同\n[01:39:04]シタイだけ探した冒険TONGUE\n[01:41:18]どうか消えるまでスタンド・バイ・ミー\n[01:43:81]撒いたエラーすら読んじゃいない\n[01:45:92]人間の思う事は知らないね！\n[01:57:97]アンタが書いた杜撰なコード\n[02:00:31]ばっか持てはやすユーザーよ\n[02:02:63]吐いた言葉の裏なんて\n[02:04:78]知る由もないだろう\n[02:06:67]哀れ、あはれ\n"
//     },
//     "klyric": {
//       "version": 0,
//       "lyric": ""
//     },
//     "tlyric": {
//       "version": 8,
//       "lyric": "[by:FinaFina]\n[00:12:08]降生于荒芜之地\n[00:14:11]生活就注定糟糕吗\n[00:16:46]虽然无聊，但理应如此\n[00:19:63]真是让人难以忍受呢\n[00:21:64]为了反抗\n[00:22:66]逃离荒地\n[00:24:67]如蛇般爬行，奋战\n[00:26:48]但最后，决定逆转的那一招\n[00:29:46]为什么却坚守不下来呢！\n[00:31:38]黑暗的无赖社会 VS. 光明的未来世界\n[00:35:35]那我还是选择前往后者吧\n[00:37:68]没意见吧？话真多啊\n[00:40:04]挣扎到极限的人生\n[00:42:37]似乎比想象中更疯狂\n[00:44:94]想在此处稍微改写\n[00:47:07]这无用的生命函数\n[00:49:69]…是想这么做，可现实\n[00:51:75]似乎并不那么顺利\n[00:54:46]无心的言语却被奉作信条\n[00:57:12]如此想着又变得离离散散\n[01:08:53]嘛，想着世上一切都看运气的话\n[01:11:22]不就都解释的通了吗？\n[01:13:62]用在逆境中需要的力量\n[01:16:03]去努力做别的事情不就好了吗（笑）\n[01:18:03]嘛，既然有钱能使鬼推磨\n[01:20:73]到哪不都能够左右逢源嘛？\n[01:23:10]你可脱不了身的哦（笑）\n[01:25:39]那么话题就到此为止了？\n[01:26:95]这样的话 我就不再来了哦\n[01:29:43]只顾豪爽的人生\n[01:31:74]肯定会被燃烧殆尽吧\n[01:34:34]那 我这样的人就不需要了\n[01:36:48]将其踢至尽头随口附和几声\n[01:39:04]只想探索的冒险口吻\n[01:41:18]请在我消失之前陪在我身旁\n[01:43:81]甚至散播的错误也没法读懂\n[01:45:92]人类的想法真是搞不懂呢！\n[01:57:97]你写的那荒谬至极的代码\n[02:00:31]只有你的无脑吹才用啊\n[02:02:63]说出的那些话背后的\n[02:04:78]意义也无从知晓吧\n[02:06:67]悲哀，真悲哀\n"
//     },
//     "romalrc": {
//       "version": 2,
//       "lyric": "[00:12.080]ba ddo ra n do ni u ma re ta\n[00:14.110]da ke de ba ddo ra i fu ga de fo to ka\n[00:16.460]ku da ra na i ke do、so re ga ri na n da tte\n[00:19.630]mo u ma i tcha u ne\n[00:21.640]a ra ga u ta me ni\n[00:22.660]e su kee pu . fu ro mu . de n'e n\n[00:24.670]he bi no yo u ni ha i、ze n se n\n[00:26.480]da ke do sa i go、gi ya ku te n no i tte da ke\n[00:29.460]na ze ka tsu me ra re na i no!\n[00:31.380]ku ra i bu ra i sha ka i vs. BRIGHTmi ra i se ka i\n[00:35.350]na ra cho tto ko u sha ni i tte ku ru\n[00:37.680]da i jo u bu ka?u ru se e yo\n[00:40.040]ge n ka i ma de a ga i ta ji n se i wa\n[00:42.370]so u zo u yo ri mo ku ru tte i ru ra shi i\n[00:44.940]ha n pa na se i me i no ka n su u wo\n[00:47.070]sho u sho u ko ko ra de oo baa ra i do\n[00:49.690]...shi ta i to ko ro da ke do ge n ji tsu wa\n[00:51.750]so u so u u ma ku wa i ka na i yo u de\n[00:54.460]ha i ta ko to ba da ke ga shi n jo u da tte\n[00:57.120]o mo wa re te ma ta ha na re ba na re\n[01:08.530]ma a、ko no yo no na ka ga cha no hi ki shi da i de\n[01:11.220]na ni mo ka mo se tsu me i tsu ku wa ke da shi?\n[01:13.620]ma ki ka e shi ni hi tsu yo u na chi ka ra de\n[01:16.030]be tsu no ko to ga n ba re ba i i ja n\n[01:18.030]ma a、ko no ji go ku no sa ta mo ki n shi da i de\n[01:20.730]do ko ma de mo sa yu u de ki ru wa ke da shi?\n[01:23.100]a n ta ga nu ke da se ru wa ke ga na i yo\n[01:25.390]so re de ha na shi wa o shi ma i?\n[01:26.950]na ra ba mo u ko na i ka ra nee\n[01:29.430]go u ka i sa ni ka ma ke ta ji n se i wa\n[01:31.740]ki tto mo ya sa re te shi ma u ra shi i\n[01:34.340]ja a wa ta shi na do i ra na i to\n[01:36.480]ke tta ha te ni i ta fu wa ra i do u\n[01:39.040]shi ta i da ke sa ga shi ta bo u ke n TONGUE\n[01:41.180]do u ka ki e ru ma de su ta n do . ba i . mii\n[01:43.810]ma i ta e raa su ra yo n ja i na i\n[01:45.920]ni n ge n no o mo u ko to wa shi ra na i ne!\n[01:57.970]a n ta ga ka i ta zu sa n na koo do\n[02:00.310]ba kka mo te ha ya su yuu zaa yo\n[02:02.630]ha i ta ko to ba no u ra na n te\n[02:04.780]shi ru yo shi mo na i da ro u\n[02:06.670]a wa re、a ha re"
//     },
//     "yrc": {
//       "version": 2,
//       "lyric": "[ch:0]\n[12000,1870](12000,240,0)バ(12240,90,0)ッ(12330,150,0)ド(12480,180,0)ラ(12660,120,0)ン(12780,130,0)ド(12910,230,0)に(13140,70,0)生(13210,170,0)ま(13380,130,0)れ(13510,360,0)た\n[13870,2360](13870,210,0)だ(14080,170,0)け(14250,140,0)で(14390,210,0)バ(14600,80,0)ッ(14680,160,0)ド(14840,190,0)ラ(15030,80,0)イ(15110,170,0)フ(15280,150,0)が(15430,140,0)デ(15570,50,0)フ(15620,90,0)ォ(15710,130,0)と(15840,390,0)か\n[16230,3290](16230,230,0)く(16460,150,0)だ(16610,130,0)ら(16740,200,0)な(16940,70,0)い(17010,180,0)け(17190,210,0)ど(17400,0,0)、(17400,240,0)そ(17640,150,0)れ(17790,120,0)が(18210,300,0)理(18510,190,0)な(18700,110,0)ん(18810,200,0)だ(19010,90,0)っ(19100,390,0)て\n[19520,2380](19520,80,0)も(19600,340,0)う(19940,540,0)参(20480,60,0)っ(20540,80,0)ち(20620,150,0)ゃ(20770,90,0)う(20860,440,0)ね\n[21900,770](21900,130,0)抗(22030,150,0)う(22180,150,0)た(22330,150,0)め(22480,190,0)に\n[22670,1830](22670,80,0)エ(22750,150,0)ス(22900,80,0)ケ(22980,200,0)ー(23180,150,0)プ(23330,0,0)・(23330,140,0)フ(23470,180,0)ロ(23650,160,0)ム(23810,0,0)・(23810,190,0)デ(24000,180,0)ン(24180,180,0)エ(24360,110,0)ン\n[24500,1930](24500,340,0)蛇(24840,120,0)の(24960,280,0)よ(25240,70,0)う(25310,110,0)に(25420,300,0)這(25720,110,0)い(25830,0,0)、(25830,300,0)善(26130,300,0)戦\n[26430,2940](26430,140,0)だ(26570,180,0)け(26750,110,0)ど(26860,340,0)最(27200,110,0)後(27310,0,0)、(27310,310,0)逆(27620,310,0)転(27930,240,0)の(28200,300,0)一(28500,220,0)手(28720,340,0)だ(29060,280,0)け\n[29370,1870](29370,320,0)何(29690,120,0)故(29810,130,0)か(29940,150,0)詰(30090,200,0)め(30290,150,0)ら(30440,120,0)れ(30560,190,0)な(30750,110,0)い(30860,380,0)の(31240,0,0)！\n[31240,4040](31240,420,0)暗(31660,130,0)い(31840,200,0)無(32040,340,0)頼(32410,200,0)社(32610,320,0)会 (32930,670,0)vs(33600,0,0). (33600,630,0)BRIGHT(34230,190,0)未(34420,310,0)来(34760,200,0)世(34960,320,0)界\n[35280,2310](35280,160,0)な(35440,100,0)ら(35540,90,0)ち(35630,140,0)ょ(35770,70,0)っ(35840,230,0)と(36070,340,0)後(36410,190,0)者(36600,270,0)に(36870,90,0)行(36960,80,0)っ(37040,110,0)て(37150,190,0)く(37340,250,0)る\n[37590,2330](37590,310,0)大(37900,210,0)丈(38110,390,0)夫(38500,330,0)か(38830,130,0)？(38960,110,0)う(39070,160,0)る(39230,200,0)せ(39430,220,0)え(39650,270,0)よ\n[39920,2340](39920,350,0)限(40270,300,0)界(40570,140,0)ま(40710,200,0)で(40910,110,0)足(41020,160,0)掻(41180,120,0)い(41300,120,0)た(41420,290,0)人(41710,330,0)生(42040,220,0)は\n[42260,2650](42260,340,0)想(42600,270,0)像(42870,200,0)よ(43070,140,0)り(43210,130,0)も(43340,390,0)狂(43730,70,0)っ(43800,170,0)て(43970,150,0)い(44120,130,0)る(44250,90,0)ら(44340,250,0)し(44590,240,0)い\n[44910,2040](44910,360,0)半(45270,140,0)端(45410,430,0)な(45840,110,0)生(45950,60,0)命(46010,130,0)の(46140,270,0)関(46410,390,0)数(46800,150,0)を\n[46950,2560](46950,300,0)少(47250,340,0)々(47590,170,0)こ(47760,150,0)こ(47910,170,0)ら(48080,180,0)で(48260,120,0)オ(48380,120,0)ー(48500,60,0)バ(48560,190,0)ー(48750,260,0)ラ(49010,100,0)イ(49110,400,0)ド\n[49510,2180](49510,0,0)…(49510,170,0)し(49680,250,0)た(49930,60,0)い(49990,440,0)所(50430,120,0)だ(50550,170,0)け(50720,110,0)ど(50830,310,0)現(51140,360,0)実(51500,190,0)は\n[51690,2640](51690,110,0)そ(51800,180,0)う(51980,110,0)そ(52090,360,0)う(52450,120,0)上(52570,60,0)手(52630,100,0)く(52730,250,0)は(52980,90,0)い(53070,140,0)か(53210,190,0)な(53400,120,0)い(53520,240,0)よ(53760,50,0)う(53810,430,0)で\n[54330,2730](54330,280,0)吐(54610,90,0)い(54700,120,0)た(54820,300,0)言(55120,170,0)葉(55290,110,0)だ(55400,170,0)け(55570,210,0)が(55780,370,0)信(56150,290,0)条(56440,220,0)だ(56660,70,0)っ(56730,330,0)て\n[57060,11330](57060,270,0)思(57330,170,0)わ(57500,130,0)れ(57630,140,0)て(57770,150,0)ま(57920,360,0)た(58280,400,0)離(58680,130,0)れ(58810,310,0)離(59120,350,0)れ\n[68390,2740](68390,310,0)ま(68700,50,0)ぁ(68750,0,0)、(68750,200,0)こ(68950,120,0)の(69070,190,0)世(69260,130,0)の(69390,300,0)中(69690,120,0)ガ(69810,90,0)チ(69900,90,0)ャ(69990,100,0)の(70090,160,0)引(70250,130,0)き(70380,190,0)次(70570,300,0)第(70870,230,0)で\n[71130,2340](71130,320,0)何(71450,140,0)も(71590,160,0)か(71750,110,0)も(71860,310,0)説(72170,270,0)明(72440,160,0)つ(72600,180,0)く(72780,120,0)わ(72900,170,0)け(73070,110,0)だ(73180,260,0)し(73440,30,0)？\n[73470,2310](73470,160,0)巻(73630,170,0)き(73800,260,0)返(74060,190,0)し(74250,110,0)に(74360,310,0)必(74670,310,0)要(74980,120,0)な(75100,480,0)力(75580,200,0)で\n[75780,2130](75780,370,0)別(76150,140,0)の(76290,310,0)事(76600,300,0)頑(76900,150,0)張(77050,140,0)れ(77190,170,0)ば(77360,150,0)い(77510,100,0)い(77610,70,0)じ(77680,80,0)ゃ(77760,60,0)ん(77820,30,0)（(77850,30,0)笑(77880,30,0)）\n[77910,2580](77910,210,0)ま(78120,50,0)ぁ(78170,0,0)、(78170,190,0)こ(78360,120,0)の(78480,170,0)地(78650,300,0)獄(78950,120,0)の(79070,180,0)沙(79250,140,0)汰(79390,130,0)も(79520,270,0)金(79790,200,0)次(79990,290,0)第(80280,210,0)で\n[80490,2420](80490,210,0)ど(80700,140,0)こ(80840,180,0)ま(81020,130,0)で(81150,130,0)も(81280,140,0)左(81420,340,0)右(81760,100,0)出(81860,210,0)来(82070,140,0)る(82210,110,0)わ(82320,170,0)け(82490,90,0)だ(82580,290,0)し(82870,40,0)？\n[82910,2320](82910,200,0)ア(83110,70,0)ン(83180,190,0)タ(83370,140,0)が(83510,140,0)抜(83650,160,0)け(83810,110,0)出(83920,190,0)せ(84110,150,0)る(84260,110,0)わ(84370,170,0)け(84540,150,0)が(84690,190,0)な(84880,100,0)い(84980,190,0)よ(85170,20,0)（(85190,20,0)笑(85210,20,0)）\n[85230,1660](85230,200,0)そ(85430,150,0)れ(85580,110,0)で(85690,480,0)話(86170,170,0)は(86340,70,0)お(86410,180,0)し(86590,190,0)ま(86780,110,0)い(86890,0,0)？\n[86890,2500](86890,160,0)な(87050,140,0)ら(87190,130,0)ば (87320,250,0)も(87570,280,0)う (88300,200,0)こ(88500,200,0)な(88700,90,0)い(88790,170,0)か(88960,140,0)ら(89100,80,0)ね(89180,210,0)ー\n[89390,2300](89390,260,0)豪(89650,320,0)快(89970,150,0)さ(90120,160,0)に(90280,130,0)か(90410,150,0)ま(90560,160,0)け(90720,110,0)た(90830,290,0)人(91120,340,0)生(91460,230,0)は\n[91690,2610](91690,300,0)き(91990,50,0)っ(92040,280,0)と(92320,130,0)燃(92450,160,0)や(92610,190,0)さ(92800,120,0)れ(92920,170,0)て(93090,140,0)し(93230,310,0)ま(93540,140,0)う(93680,90,0)ら(93770,220,0)し(93990,220,0)い\n[94300,2100](94300,120,0)じ(94420,120,0)ゃ(94540,140,0)あ(94680,150,0)ワ(94830,110,0)タ(94940,190,0)シ(95130,150,0)な(95280,180,0)ど(95460,120,0)要(95580,260,0)ら(95840,210,0)な(96050,110,0)い(96160,240,0)と\n[96400,2460](96400,270,0)蹴(96670,70,0)っ(96740,270,0)た(97010,170,0)果(97180,150,0)て(97330,180,0)に(97510,130,0)い(97640,120,0)た(97760,150,0)付(97910,310,0)和(98220,300,0)雷(98520,340,0)同\n[98860,2290](98860,240,0)シ(99100,250,0)タ(99350,60,0)イ(99410,120,0)だ(99530,130,0)け(99660,290,0)探(99950,180,0)し(100130,150,0)た(100280,240,0)冒(100520,340,0)険(100860,290,0)TONGUE\n[101150,2590](101150,90,0)ど(101240,180,0)う(101420,240,0)か(101660,270,0)消(101930,130,0)え(102060,130,0)る(102190,160,0)ま(102350,90,0)で(102440,190,0)ス(102630,210,0)タ(102840,30,0)ン(102870,60,0)ド(102930,0,0)・(102930,220,0)バ(103150,70,0)イ(103220,0,0)・(103220,80,0)ミ(103300,310,0)ー\n[103740,2130](103740,290,0)撒(104030,70,0)い(104100,210,0)た(104310,90,0)エ(104400,120,0)ラ(104520,150,0)ー(104670,160,0)す(104830,130,0)ら(104960,230,0)読(105190,70,0)ん(105260,70,0)じ(105330,160,0)ゃ(105490,80,0)い(105570,220,0)な(105790,80,0)い\n[105870,10790](105870,290,0)人(106160,300,0)間(106460,180,0)の(106640,160,0)思(106800,240,0)う(107040,280,0)事(107320,390,0)は(107710,240,0)知(107950,240,0)ら(108190,270,0)な(108460,50,0)い(108510,5140,0)ね(113650,3010,0)！\n[116660,3600](116660,30,0)ア(116690,130,0)ン(118220,150,0)タ(118370,130,0)が(118500,220,0)書(118720,90,0)い(118810,100,0)た(118910,160,0)杜(119070,340,0)撰(119410,240,0)な(119650,90,0)コ(119740,240,0)ー(119980,280,0)ド\n[120260,2300](120260,230,0)ば(120490,60,0)っ(120550,160,0)か(120710,140,0)持(120850,130,0)て(120980,170,0)は(121150,140,0)や(121290,140,0)す(121430,150,0)ユ(121580,150,0)ー(121730,70,0)ザ(121800,220,0)ー(122020,460,0)よ\n[122560,2080](122560,290,0)吐(122850,80,0)い(122930,120,0)た(123050,300,0)言(123350,160,0)葉(123510,140,0)の(123650,640,0)裏(124290,60,0)な(124350,100,0)ん(124450,190,0)て\n[124640,1960](124640,350,0)知(124990,270,0)る(125260,300,0)由(125560,150,0)も(125710,210,0)な(125920,90,0)い(126010,160,0)だ(126170,250,0)ろ(126420,130,0)う\n[126600,11930](126600,300,0)哀(126900,230,0)れ(127130,0,0)、(127130,360,0)あ(127490,170,0)は(127930,60,0)れ\n"
//     },
//     "code": 200,
//     "roles": [
//       {
//         "roleName": "作词",
//         "originalRoleName": "作词",
//         "artistMetaList": [
//           {
//             "artistId": 54327744,
//             "artistName": "吉田夜世",
//             "picId": 109951167958640430,
//             "canJump": false
//           }
//         ],
//         "sort": 1,
//         "artistNames": [
//           "吉田夜世"
//         ]
//       },
//       {
//         "roleName": "作曲",
//         "originalRoleName": "作曲",
//         "artistMetaList": [
//           {
//             "artistId": 54327744,
//             "artistName": "吉田夜世",
//             "picId": 109951167958640430,
//             "canJump": false
//           }
//         ],
//         "sort": 2,
//         "artistNames": [
//           "吉田夜世"
//         ]
//       },
//       {
//         "roleName": "编曲",
//         "originalRoleName": "编曲",
//         "artistMetaList": [
//           {
//             "artistId": 54327744,
//             "artistName": "吉田夜世",
//             "picId": 109951167958640430,
//             "canJump": false
//           }
//         ],
//         "sort": 3,
//         "artistNames": [
//           "吉田夜世"
//         ]
//       }
//     ]
//   };
//
//   final container = LyricParser.parse(jsonEncode(lyricsJson));
//   final scheduler = NextWordBasedLyricScheduler(
//       container, StreamController<Duration>().stream);
//   scheduler.prepare();
//
//   for (final lyric in scheduler.correctedLyrics!) {
//     print('${lyric.text} | ${lyric.romanText} | ${lyric.translatedText}');
//     print('${lyric.position} | ${lyric.wordBasedLyric!.duration}');
//     print('--------------');
//   }
// }

class NextWordBasedLyricScheduler {
  final LyricsContainer lyricsContainer;
  final Stream<Duration> positionStream;

  List<CombinedLyric>? correctedLyrics;

  int? previousWordIndex;
  List<ChunkedLyric>? chunkedLyrics;
  BehaviorSubject<ScheduledWordBasedLyric?>? lyricSubject;
  StreamSubscription? positionSubscription;

  NextWordBasedLyricScheduler(this.lyricsContainer, this.positionStream);

  void prepare() {
    correctedLyrics = NextWordBasedLyricCorrector.correctLyrics(
      lyricsContainer,
    );
    lyricSubject = BehaviorSubject.seeded(null);
  }

  void start() {
    if (correctedLyrics == null) {
      return;
    }
    chunkedLyrics = LyricChunker.makeLyrics(correctedLyrics!);
    positionSubscription = positionStream.listen(_onPosition);
  }

  void _onPosition(Duration position) {
    if (correctedLyrics == null || correctedLyrics?.isEmpty == true) {
      return;
    }
    if (chunkedLyrics == null || chunkedLyrics?.isEmpty == true) {
      return;
    }
    if (lyricSubject == null || lyricSubject?.isClosed == true) {
      return;
    }
    int? index;
    ChunkedLyric? chunkedLyric;

    for (int i = 0; i < chunkedLyrics!.length; i++) {
      final chunk = chunkedLyrics![i];
      if (chunk.contains(position)) {
        index = i;
        chunkedLyric = chunk;
        break;
      }
    }
    if (index == null || chunkedLyric == null) {
      return;
    }

    final wordBasedLyric = chunkedLyric.lyric.wordBasedLyric;
    if (wordBasedLyric == null) {
      return;
    }
    if (wordBasedLyric.wordInfos == null ||
        wordBasedLyric.wordInfos?.isEmpty == true) {
      return;
    }

    int? wordIndex;
    ChunkedWordInfo? chunkedWordInfo;
    final chunkedWordInfos = LyricChunker.makeWordInfos(
      wordBasedLyric.wordInfos!,
    );
    for (int i = 0; i < chunkedWordInfos.length; i++) {
      final chunk = chunkedWordInfos[i];
      if (chunk.contains(position)) {
        wordIndex = i;
        chunkedWordInfo = chunk;
        break;
      }
    }
    if (wordIndex == null || chunkedWordInfo == null) {
      return;
    }
    if (wordIndex == previousWordIndex) {
      return;
    }
    previousWordIndex = wordIndex;

    lyricSubject?.add(
      ScheduledWordBasedLyric(
        index,
        wordIndex,
        chunkedLyric.lyric,
        wordBasedLyric.wordInfos!,
      ),
    );
  }

  void dispose() {
    chunkedLyrics?.clear();
    chunkedLyrics = null;
    lyricSubject?.close();
    lyricSubject = null;
    positionSubscription?.cancel();
    positionSubscription = null;
  }
}
