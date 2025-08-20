import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 author: @albertjjimenezp
class MockPageManager extends PageManager {
  MockPageManager({required super.initial});

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

  void back() {
    backCalled = true;
  }

  String setPageTitle(String title, [int? color]) {
    setPageTitleCalled = true;
    setPageTitleArg = title;
    return title;
  }

  void setHomePage(Widget widget, [Object? arguments]) {
    pushRouteName = '/';
    pushWidget = widget;
    pushAndReplacementArguments = arguments;
  }

  void pushAndReplacement(
    String routeName,
    Widget widget, [
    Object? arguments,
  ]) {
    pushAndReplacementRouteName = routeName;
    pushAndReplacementWidget = widget;
    pushAndReplacementArguments = arguments;
  }

  void pushNamedAndReplacement(String routeName, [Object? arguments]) {
    pushAndReplacementRouteName = routeName;
    pushAndReplacementArguments = arguments;
  }

  void clearHistory() {
    clearHistoryCalled = true;
  }

  void update() {
    isUpdated = true;
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }
}
