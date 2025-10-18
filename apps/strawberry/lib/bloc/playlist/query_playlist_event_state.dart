
import 'package:domain/entity/playlist_query_entity.dart';
import 'package:strawberry/bloc/playlist/playlist_bloc.dart';

/// 请求 JSON: {
//     "id": "123456",
//     "t": "-1",
//     "n": "0",
//     "s": "0",
//     "e_r": true,
//     "header": "{\"os\":\"pc\",\"appver\":\"xxx\",\"deviceId\":\"xxx\",\"requestId\":\"xxx\",\"clientSign\":\"xxx\",\"osver\":\"xxx\"}"
// }
/// 成功返回：{
//     "code": 200,
//     "relatedVideos": null,
//     "playlist": {
//         "id": 123456,
//         "name": "xxx",
//         "coverImgId": 123456,
//         "coverImgUrl": "xxx",
//         "coverImgId_str": "xxx",
//         "adType": 0,
//         "userId": 123456,
//         "createTime": 123456,
//         "status": 0,
//         "opRecommend": false,
//         "highQuality": false,
//         "newImported": false,
//         "updateTime": 123456,
//         "trackCount": 123456,
//         "specialType": 5,
//         "privacy": 0,
//         "trackUpdateTime": 123456,
//         "commentThreadId": "A_PL_0_123456",
//         "playCount": 7193,
//         "trackNumberUpdateTime": 123456,
//         "subscribedCount": 0,
//         "cloudTrackCount": 7,
//         "ordered": true,
//         "description": "",
//         "tags": [
//
//         ],
//         "updateFrequency": null,
//         "backgroundCoverId": 0,
//         "backgroundCoverUrl": null,
//         "titleImage": 0,
//         "titleImageUrl": null,
//         "detailPageTitle": null,
//         "englishTitle": null,
//         "officialPlaylistType": null,
//         "copied": false,
//         "relateResType": null,
//         "coverStatus": 1,
//         "subscribers": [
//
//         ],
//         "subscribed": false,
//         "creator": {
//
//         },
//         "tracks": [
//{
//                 "name": "Talk talk featuring troye sivan",
//                 "mainTitle": null,
//                 "additionalTitle": null,
//                 "id": 2626293184,
//                 "pst": 0,
//                 "t": 0,
//                 "ar": [
//                     {
//                         "id": 53092,
//                         "name": "Charli xcx",
//                         "tns": [
//
//                         ],
//                         "alias": [
//
//                         ]
//                     },
//                     {
//                         "id": 45129,
//                         "name": "Troye Sivan",
//                         "tns": [
//
//                         ],
//                         "alias": [
//
//                         ]
//                     }
//                 ],
//                 "alia": [
//
//                 ],
//                 "pop": 85,
//                 "st": 0,
//                 "rt": "",
//                 "fee": 1,
//                 "v": 39,
//                 "crbt": null,
//                 "cf": "",
//                 "al": {
//                     "id": 247646607,
//                     "name": "Talk talk featuring troye sivan",
//                     "picUrl": "http://p3.music.126.net/6US2SkgqK4Be3UDUuNbgDg==/109951169953400617.jpg",
//                     "tns": [
//
//                     ],
//                     "pic_str": "109951169953400617",
//                     "pic": 109951169953400617
//                 },
//                 "dt": 173076,
//                 "h": {
//                     "br": 320002,
//                     "fid": 0,
//                     "size": 6925627,
//                     "vd": -60079,
//                     "sr": 44100
//                 },
//                 "m": {
//                     "br": 192002,
//                     "fid": 0,
//                     "size": 4155394,
//                     "vd": -57532,
//                     "sr": 44100
//                 },
//                 "l": {
//                     "br": 128002,
//                     "fid": 0,
//                     "size": 2770277,
//                     "vd": -55988,
//                     "sr": 44100
//                 },
//                 "sq": {
//                     "br": 1701376,
//                     "fid": 0,
//                     "size": 36808623,
//                     "vd": -60105,
//                     "sr": 44100
//                 },
//                 "hr": null,
//                 "a": null,
//                 "cd": "01",
//                 "no": 1,
//                 "rtUrl": null,
//                 "ftype": 0,
//                 "rtUrls": [
//
//                 ],
//                 "djId": 0,
//                 "copyright": 1,
//                 "s_id": 0,
//                 "mark": 17181188096,
//                 "originCoverType": 0,
//                 "originSongSimpleData": null,
//                 "tagPicList": null,
//                 "resourceState": true,
//                 "version": 5,
//                 "songJumpInfo": null,
//                 "entertainmentTags": null,
//                 "awardTags": null,
//                 "displayTags": null,
//                 "single": 0,
//                 "noCopyrightRcmd": null,
//                 "alg": null,
//                 "displayReason": null,
//                 "rtype": 0,
//                 "rurl": null,
//                 "mst": 9,
//                 "cp": 7002,
//                 "mv": 0,
//                 "publishTime": 1726070400000
//             }
//         ],
//         "videoIds": null,
//         "videos": null,
//         "trackIds": [
//             {
//                 "id": 431853993,
//                 "v": 9,
//                 "t": 0,
//                 "at": 1578214233859,
//                 "alg": null,
//                 "uid": 2003435188,
//                 "rcmdReason": "",
//                 "rcmdReasonTitle": "编辑推荐",
//                 "sc": null,
//                 "f": null,
//                 "sr": null,
//                 "dpr": null
//             }
//         ],
//         "bannedTrackIds": null,
//         "mvResourceInfos": null,
//         "shareCount": 0,
//         "commentCount": 1,
//         "remixVideo": null,
//         "newDetailPageRemixVideo": null,
//         "sharedUsers": null,
//         "historySharedUsers": null,
//         "gradeStatus": "NONE",
//         "score": null,
//         "algTags": null,
//         "distributeTags": [
//
//         ],
//         "trialMode": 1,
//         "displayTags": null,
//         "displayUserInfoAsTagOnly": false,
//         "playlistType": "xxx",
//         "bizExtInfo": {
//
//         }
//     },
//     "urls": null,
//     "privileges": [
//
//     ],
//     "sharedPrivilege": null,
//     "resEntrance": null,
//     "fromUsers": null,
//     "fromUserCount": 0,
//     "songFromUsers": null
// }
/// 参数错误返回：{"code":400,"message":"请求参数错误","debugInfo":null,"data":null,"failData":null,"msg":"请求参数错误"}
/// 请求 JSON 中的 n 参数代表请求的歌曲数量，对应到返回体中的 track 字段，track 为一数组，其长度与 n 相同，内容为歌曲具体信息
/// 请求 JSON 中的 s 参数代表请求的收藏者数量，对应到返回体的 subscribers 字段，subscribers 为一数组，其长度与 s 相同，内容为用户信息
/// 返回体中 trackIds 包含所有歌曲的 id
class AttemptQueryPlaylistEvent extends PlaylistEvent {
  final int id;
  final int songCount;

  AttemptQueryPlaylistEvent(this.id, this.songCount);
}

/// 参数 n 为 0, 仅获取基础信息和 songIds
class AttemptQueryBasicPlaylistEvent extends PlaylistEvent {
  final int id;

  AttemptQueryBasicPlaylistEvent(this.id);
}

class QueryPlaylistSuccess extends PlaylistState {
  final PlaylistQueryEntity playlistQuery;

  QueryPlaylistSuccess(this.playlistQuery);
}

class QueryBasicPlaylistSuccess extends PlaylistState {
  final PlaylistQueryEntity playlistQuery;

  QueryBasicPlaylistSuccess(this.playlistQuery);
}