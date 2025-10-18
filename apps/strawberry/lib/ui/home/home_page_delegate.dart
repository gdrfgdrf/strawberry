import 'package:strawberry/ui/abstract_delegate.dart';
import 'package:strawberry/ui/abstract_widget_provider.dart';
import 'package:strawberry/ui/home/home_appbar.dart';

class HomePageDelegate extends AbstractDelegate {
  @override
  List<AbstractWidgetProviderFactory> widgetProviderFactories() {
    return [HomeAppBarProviderFactory<HomePageDelegate>(this)];
  }
}
