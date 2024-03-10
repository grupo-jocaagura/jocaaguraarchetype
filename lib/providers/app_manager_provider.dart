import 'package:flutter/widgets.dart';

import '../blocs/app_manager.dart';

class AppManagerProvider extends InheritedWidget {
  const AppManagerProvider({
    required this.appManager,
    required super.child,
    super.key,
  });
  final AppManager appManager;

  static AppManager of(BuildContext context) {
    final AppManagerProvider? result =
        context.dependOnInheritedWidgetOfExactType<AppManagerProvider>();
    assert(result != null, 'No AppManager found in context');
    return result!.appManager;
  }

  @override
  bool updateShouldNotify(AppManagerProvider oldWidget) => false;
}

extension AppManagerExtension on BuildContext {
  AppManager get appManager => AppManagerProvider.of(this);
}
