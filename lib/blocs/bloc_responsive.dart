import 'dart:async';

import 'package:flutter/material.dart';

import '../consts/enum_screen_size.dart';
import '../entities/entity_bloc.dart';

class BlocResponsive extends BlocModule {
  static String name = 'responsiveBloc';

  final BlocGeneral<Size> _blocSizeGeneral = BlocGeneral<Size>(Size.zero);

  Stream<Size> get appScreenSizeStream => _blocSizeGeneral.stream;

  Size get value => _blocSizeGeneral.value;
  double get drawerWidth => size.width - workAreaSize.width;
  double get secondaryDrawerWidth => columnWidth;

  double get appBarHeight => 60.0;
  double get screenHeightWithoutAppbar =>
      showAppbar ? size.height - appBarHeight : size.height;
  bool showAppbar = true;

  void setSizeFromContext(BuildContext context) {
    final Size sizeTmp = MediaQuery.of(context).size;
    if (sizeTmp.width != value.width || sizeTmp.height != value.height) {
      _blocSizeGeneral.value = sizeTmp;
    }
    workAreaSize = sizeTmp;
  }

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

  ScreenSizeEnum get getDeviceType {
    if (size.width >= 1200) {
      return ScreenSizeEnum.desktop;
    } else if (size.width < 1200 && size.width > 520) {
      return ScreenSizeEnum.tablet;
    }
    return ScreenSizeEnum.movil;
  }

  bool get isMovil => getDeviceType == ScreenSizeEnum.movil;

  bool get isTablet => getDeviceType == ScreenSizeEnum.tablet;

  bool get isDesktop => getDeviceType == ScreenSizeEnum.desktop;

  bool get isTv => getDeviceType == ScreenSizeEnum.tv;

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
  }
}
