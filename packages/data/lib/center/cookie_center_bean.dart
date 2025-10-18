
import 'dart:io';
import 'dart:isolate';

enum CookieAction {
  load, save, delete, deleteAll
}

class CookieRequest {
  final CookieAction action;
  final Uri? uri;
  final SendPort replyPort;

  final dynamic argument;

  CookieRequest(this.action, this.uri, this.replyPort, this.argument);
}