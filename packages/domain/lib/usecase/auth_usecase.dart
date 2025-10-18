
import 'package:dartz/dartz.dart';
import 'package:domain/usecase/strawberry_usecase.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:shared/api/device.dart';

import '../entity/anonimous_entity.dart';
import '../entity/login_result.dart';
import '../repository/auth_repository.dart';
import '../result/result.dart';

abstract class AuthUseCase {
  Future<Either<Failure, AnonimousEntity>> registerAnonimous(String deviceId);

  Future<Either<Failure, LoginResult>> loginCellphoneDesktop(
      String countryCode,
      String appVer,
      String deviceId,
      String requestId,
      ClientSign clientSign,
      String osVer,
      String cellphone,
      String password,
      );

  Future<Either<Failure, void>> refreshToken_Type1(int id);
  Future<Either<Failure, String>> refreshToken_Type2(int id);
}

class AuthUseCaseImpl extends StrawberryUseCase implements AuthUseCase {
  final AbstractAuthRepository authRepository;

  AuthUseCaseImpl(this.authRepository);

  @override
  Future<Either<Failure, AnonimousEntity>> registerAnonimous(String deviceId) async {
    serviceLogger!.trace("registering anonimous");
    try {
      final result = await authRepository.registerAnonimous(deviceId);

      return Right(result);
    } catch (e, s) {
      serviceLogger!.error("registering anonimous error: $e\n$s");
      return Left(
        Failure(e, s),
      );
    }
  }

  @override
  Future<Either<Failure, LoginResult>> loginCellphoneDesktop(
      String countryCode,
      String appVer,
      String deviceId,
      String requestId,
      ClientSign clientSign,
      String osVer,
      String cellphone,
      String password,
      ) async {
    serviceLogger!.trace("login cellphone desktop");
    try {
      final result = await authRepository.loginCellphoneDesktop(
        countryCode,
        appVer,
        deviceId,
        requestId,
        clientSign,
        osVer,
        cellphone,
        password,
      );

      return Right(result);
    } catch (e, s) {
      serviceLogger!.error("login cellphone desktop error: $e\n$s");
      return Left(
        Failure(e, s),
      );
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken_Type1(int id) async {
    serviceLogger!.trace("refreshing token 1");
    try {
      final result = await authRepository.refreshToken_Type1(id);
      return Right(result);
    } catch (e, s) {
      serviceLogger!.error("refreshing token 1 error: $e\n$s");
      return Left(Failure(e, s));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken_Type2(int id) async {
    serviceLogger!.trace("refreshing token 2");
    try {
      final result = await authRepository.refreshToken_Type2(id);
      return Right(result);
    } catch (e, s) {
      serviceLogger!.error("refreshing token 2 error: $e\n$s");
      return Left(Failure(e, s));
    }
  }

}