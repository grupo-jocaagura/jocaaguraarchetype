import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../consts/app_constants.dart';
import '../consts/enum_screen_size.dart';

/// A BLoC (Business Logic Component) for managing responsive layout properties.
///
/// The `BlocResponsive` class provides utility methods and streams to handle
/// responsive layout behaviors such as screen size, app bar visibility, and
/// layout grid properties. It adapts layouts based on device type (mobile,
/// tablet, desktop, TV).
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/bloc_responsive.dart';
/// import 'package:flutter/material.dart';
///
/// void main() {
///   final blocResponsive = BlocResponsive();
///
///   // Set the size using a context
///   blocResponsive.setSizeFromContext(context);
///
///   // Access layout properties
///   print('Columns: ${blocResponsive.columnsNumber}');
///   print('Is Desktop: ${blocResponsive.isDesktop}');
/// }
/// ```
class BlocResponsive extends BlocModule {
  /// The name identifier for the BLoC, used for tracking or debugging.
  static String name = 'responsiveBloc';

  /// Stream controller for app screen size.
  final BlocGeneral<Size> _blocSizeGeneral = BlocGeneral<Size>(Size.zero);

  final BlocGeneral<bool> _blocShowAppbar = BlocGeneral<bool>(true);

  /// A stream of app screen sizes.
  ///
  /// Emits updates when the screen size changes.
  Stream<Size> get appScreenSizeStream => _blocSizeGeneral.stream;

  /// A stream of app bar visibility states.
  ///
  /// Emits updates when the app bar visibility changes.
  Stream<bool> get showAppbarStream => _blocShowAppbar.stream;

  /// Gets the current screen size.
  Size get value => _blocSizeGeneral.value;
  double get drawerWidth => size.width - workAreaSize.width;
  double get secondaryDrawerWidth => columnWidth;

  double get appBarHeight => kAppBarHeight;
  double get screenHeightWithoutAppbar =>
      showAppbar ? size.height - appBarHeight : size.height;

  /// Gets whether the app bar is visible.
  bool get showAppbar => _blocShowAppbar.value;

  /// Sets whether the app bar is visible.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocResponsive.showAppbar = false;
  /// ```
  set showAppbar(bool val) {
    _blocShowAppbar.value = val;
  }

  bool get showAppBarStreamIsClosed => _blocShowAppbar.isClosed;
  bool get appScreenSizeStreamIsClosed => _blocSizeGeneral.isClosed;

  /// Updates the screen size using the [context].
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocResponsive.setSizeFromContext(context);
  /// ```
  void setSizeFromContext(BuildContext context) {
    final Size sizeTmp = MediaQuery.of(context).size;
    if (sizeTmp.width != value.width || sizeTmp.height != value.height) {
      _blocSizeGeneral.value = sizeTmp;
    }
    workAreaSize = sizeTmp;
  }

  /// Updates the screen size for testing purposes.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocResponsive.setSizeForTesting(Size(800, 600));
  /// ```
  void setSizeForTesting(Size sizeTmp) {
    if (sizeTmp.width != value.width || sizeTmp.height != value.height) {
      _blocSizeGeneral.value = sizeTmp;
    }
    workAreaSize = sizeTmp;
  }

  Size get size => value;

  Size _workAreaSize = Size.zero;

  set workAreaSize(Size sizeOfWorkArea) {
    if (isDesktop) {
      _workAreaSize = Size(sizeOfWorkArea.width * 0.86, sizeOfWorkArea.height);
      return;
    }
    if (isTv) {
      _workAreaSize = Size(sizeOfWorkArea.width * 0.8, sizeOfWorkArea.height);
      return;
    }
    _workAreaSize = sizeOfWorkArea;
  }

  Size get workAreaSize => isMovil ? size : _workAreaSize;

  int get columnsNumber {
    int tmp = 4;
    if (isTablet) {
      tmp = 8;
    }
    if (isDesktop || isTv) {
      tmp = 12;
    }
    return tmp;
  }

  double get marginWidth {
    double tmp = 16.0;
    if (isTablet) {
      tmp = 32;
    }
    if (isDesktop || isTv) {
      tmp = 64;
    }
    return tmp;
  }

  double get gutterWidth {
    double tmp = marginWidth * 2;
    tmp = tmp / columnsNumber;
    return tmp.floorToDouble();
  }

  int numberOfGutters(int numberOfColumns) {
    if (numberOfColumns < 1) {
      return 0;
    }
    return numberOfColumns - 1;
  }

  double get columnWidth {
    double tmp = workAreaSize.width;
    tmp = tmp - (marginWidth * 2);
    tmp = tmp - (numberOfGutters(columnsNumber) * gutterWidth);
    tmp = tmp / columnsNumber;
    return tmp;
  }

  /// Gets the current device type based on screen width.
  ///
  /// Returns a [ScreenSizeEnum] indicating the device type (mobile, tablet, desktop, TV).
  ///
  /// ## Example
  ///
  /// ```dart
  /// print('Device Type: ${blocResponsive.getDeviceType}');
  /// ```
  ScreenSizeEnum get getDeviceType {
    if (size.width >= 1920) {
      return ScreenSizeEnum.tv;
    } else if (size.width < 1920 && size.width > 1100) {
      return ScreenSizeEnum.desktop;
    } else if (size.width <= 1100 && size.width > 520) {
      return ScreenSizeEnum.tablet;
    }
    return ScreenSizeEnum.movil;
  }

  /// Gets whether the current device is a mobile.
  bool get isMovil => getDeviceType == ScreenSizeEnum.movil;

  /// Gets whether the current device is a tablet.
  bool get isTablet => getDeviceType == ScreenSizeEnum.tablet;

  /// Gets whether the current device is a desktop.
  bool get isDesktop => getDeviceType == ScreenSizeEnum.desktop;

  /// Gets whether the current device is a TV.
  bool get isTv => getDeviceType == ScreenSizeEnum.tv;

  /// Calculates the width of a specified number of columns.
  ///
  /// ## Example
  ///
  /// ```dart
  /// double width = blocResponsive.widthByColumns(4);
  /// print('Width for 4 columns: $width');
  /// ```
  double widthByColumns(int numberOfColumns) {
    numberOfColumns = numberOfColumns.abs();
    double tmp = columnWidth * numberOfColumns;
    if (numberOfColumns > 1) {
      tmp = tmp + (gutterWidth * (numberOfColumns - 1));
    }

    return tmp;
  }

  @override
  FutureOr<void> dispose() {
    _blocSizeGeneral.dispose();
    _blocShowAppbar.dispose();
  }
}
