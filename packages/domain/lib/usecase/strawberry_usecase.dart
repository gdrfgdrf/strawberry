
import 'package:natives/wrap/strawberry_logger_wrapper.dart';

abstract class StrawberryUseCase {
  DartStrawberryServiceLogger? serviceLogger;

  StrawberryUseCase() {
    serviceLogger = openService("UseCaseService-$runtimeType");
    serviceLogger!.info("creating: $runtimeType");
  }

}