
import 'package:domain/entity/login_result.dart';

abstract class AbstractQrCodeRepository {
  Future<String> getUniKey();
  Future<QrCodeResult> tryLogin(String uniKey);
}