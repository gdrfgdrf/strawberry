import 'package:domain/navigation_service.dart';
import 'package:get_it/get_it.dart';
import 'package:strawberry/app_config.dart';
import 'package:strawberry/ui/router/home_router.dart';
import 'package:strawberry/ui/router/home_navigator_impl.dart';
import 'package:strawberry/ui/router/main_router.dart';

import 'main_navigator_impl.dart';

class NavigatorFactoryImpl implements NavigatorFactory {
  @override
  AbstractMainNavigator createMain() {
    return MainNavigatorImpl(
      AppConfig.mainNavigatorKey,
      GetIt.instance.get<MainRouter>(),
    );
  }

  @override
  AbstractHomeNavigator createHome() {
    return HomeNavigatorImpl(
      AppConfig.homeNavigatorKey,
      GetIt.instance.get<HomeRouter>(),
    );
  }
}
