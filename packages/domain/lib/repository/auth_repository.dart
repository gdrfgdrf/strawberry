import 'package:domain/entity/anonimous_entity.dart';
import 'package:domain/entity/login_result.dart';
import 'package:shared/api/device.dart';

abstract class AbstractAuthRepository {
  Future<AnonimousEntity> registerAnonimous(String deviceId);

  Future<LoginResult> loginCellphoneDesktop(
    String countryCode,
    String appVer,
    String deviceId,
    String requestId,
    ClientSign clientSign,
    String osVer,
    String cellphone,
    String password,
  );

  Future<void> refreshToken_Type1(int id);
  Future<String> refreshToken_Type2(int id);
}
