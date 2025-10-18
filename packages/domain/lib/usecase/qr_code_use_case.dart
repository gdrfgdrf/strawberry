import 'package:dartz/dartz.dart';
import 'package:domain/entity/login_result.dart';
import 'package:domain/repository/qr_code_repository.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/strawberry_usecase.dart';

abstract class QrCodeUseCase {
  Future<Either<Failure, String>> getUniKey();
  Future<Either<Failure, QrCodeResult>> tryLogin(String uniKey);
}

class QrCodeUseCaseImpl extends StrawberryUseCase implements QrCodeUseCase {
  final AbstractQrCodeRepository qrCodeRepository;

  QrCodeUseCaseImpl(this.qrCodeRepository);

  @override
  Future<Either<Failure, String>> getUniKey() async {
    serviceLogger!.trace("getting unikey");
    try {
      final result = await qrCodeRepository.getUniKey();
      return Right(result);
    } catch (e, s) {
      serviceLogger!.error("getting unikey error: $e\n$s");
      return Left(Failure(e, s));
    }
  }

  @override
  Future<Either<Failure, QrCodeResult>> tryLogin(String uniKey) async {
    serviceLogger!.trace("trying login, unikey: $uniKey");
    try {
       final result = await qrCodeRepository.tryLogin(uniKey);
       return Right(result);
    } catch (e, s) {
      serviceLogger!.error("trying login error, unikey: $uniKey: $e\n$s");
      return Left(Failure(e, s));
    }
  }
}
