import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/navigator/page_manager.dart';

// revisado 10/03/2024 author: @albertjjimenezp
class MockPageManager extends PageManager {
  bool backCalled = false;
  bool isUpdated = false;
  bool isDisposed = false;
  bool setPageTitleCalled = false;
  String? setPageTitleArg;
  bool pushCalled = false;
  String? pushRouteName;
  Widget? pushWidget;
  Widget? pushAndReplacementWidget;
  Object? pushAndReplacementArguments;
  bool clearHistoryCalled = false;

  bool get goBackCalled => backCalled;

  String pushAndReplacementRouteName = '';

  @override
  void back() {
    backCalled = true;
  }

  @override
  String setPageTitle(String title, [int? color]) {
    setPageTitleCalled = true;
    setPageTitleArg = title;
    return title;
  }

  @override
  void setHomePage(Widget widget, [Object? arguments]) {
    pushRouteName = '/';
    pushWidget = widget;
    pushAndReplacementArguments = arguments;
  }

  @override
  void push(String routeName, Widget widget, [Object? arguments]) {
    pushCalled = true;
    pushRouteName = routeName;
    pushWidget = widget;
    pushAndReplacementArguments = arguments;
  }

  @override
  void pushAndReplacement(
    String routeName,
    Widget widget, [
    Object? arguments,
  ]) {
    pushAndReplacementRouteName = routeName;
    pushAndReplacementWidget = widget;
    pushAndReplacementArguments = arguments;
  }

  @override
  void pushNamedAndReplacement(String routeName, [Object? arguments]) {
    pushAndReplacementRouteName = routeName;
    pushAndReplacementArguments = arguments;
  }

  @override
  void clearHistory() {
    clearHistoryCalled = true;
  }

  @override
  void update() {
    isUpdated = true;
  }

  @override
  void pushNamed(String routeName, [Object? arguments]) {
    final Widget widget = getPageFromDirectory(routeName).child;
    push(routeName, widget, arguments);
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }
}
