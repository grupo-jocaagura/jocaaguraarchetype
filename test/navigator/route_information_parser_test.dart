import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/navigator/page_manager.dart';
import 'package:jocaaguraarchetype/navigator/route_information_parser.dart';

import '../ui/pages/page_404_widget_test.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('MyAppRouteInformationParser', () {
    late MyAppRouteInformationParser myAppRouteInformationParser;
    late MockPageManager pageManager;

    setUp(() {
      pageManager = MockPageManager();
      myAppRouteInformationParser = MyAppRouteInformationParser(pageManager);
    });

    test('should parse route information', () async {
      // Define the RouteInformation to be parsed
      final RouteInformation routeInformation =
          RouteInformation(uri: Uri.parse('/'));

      // Parse the RouteInformation
      final PageManager parsedPageManager = await myAppRouteInformationParser
          .parseRouteInformation(routeInformation);

      // Check if the parsed PageManager is correct
      expect(parsedPageManager, isA<PageManager>());
      expect(parsedPageManager.getCurrentUrl()?.uri.path, '/');
    });

    test('should restore route information', () {
      // Define the PageManager to be restored
      final MockPageManager configuration = MockPageManager();
      configuration.setCurrentUrl(RouteInformation(uri: Uri.parse('/')));

      // Restore the RouteInformation
      final RouteInformation? restoredRouteInformation =
          myAppRouteInformationParser.restoreRouteInformation(configuration);

      // Check if the restored RouteInformation is correct
      expect(restoredRouteInformation, isA<RouteInformation>());
      expect(restoredRouteInformation!.uri.path, '/');
    });
  });
}
