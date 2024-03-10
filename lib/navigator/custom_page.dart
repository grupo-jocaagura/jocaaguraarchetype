import 'package:flutter/material.dart';

class CustomPage extends MaterialPage<CustomPage> {
  const CustomPage({
    required super.child,
    required this.title,
    required this.routeName,
    this.onPageCallback,
    this.onPagePathSegmentsCallback,
    Map<String, dynamic>? super.arguments,
    super.key,
  }) : super(
          name: routeName,
        );
  final String title;
  final String routeName;
  final Function(Map<String, dynamic>? arguments)? onPageCallback;
  final Function(List<String>? pathSegments)? onPagePathSegmentsCallback;

  @override
  Route<CustomPage> createRoute(BuildContext context) {
    return MaterialPageRoute<CustomPage>(
      settings: this,
      builder: (BuildContext context) => child,
    );
  }
}
