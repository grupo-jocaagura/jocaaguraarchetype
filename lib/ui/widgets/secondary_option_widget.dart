part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A widget that represents an option in a secondary menu.
///
/// The `SecondaryOptionWidget` displays an icon, a label, and an optional description
/// for an option in a menu. When tapped, it triggers the [onPressed] callback and,
/// optionally, closes the drawer if [getOutOnTap] is `true`.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
/// import 'package:flutter/material.dart';
///
/// void main() {
///   runApp(MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: Scaffold(
///         appBar: AppBar(title: Text('Secondary Option Example')),
///         body: Center(
///           child: SecondaryOptionWidget(
///             onPressed: () {
///               print('Option selected');
///             },
///             label: 'Settings',
///             icondata: Icons.settings,
///             description: 'Adjust your preferences',
///             getOutOnTap: true,
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class SecondaryOptionWidget extends StatelessWidget {
  /// Creates a `SecondaryOptionWidget`.
  ///
  /// - [onPressed]: Callback function triggered when the option is tapped.
  /// - [label]: The label for the option.
  /// - [icondata]: The icon to display alongside the label.
  /// - [description]: An optional description for the option.
  /// - [getOutOnTap]: If `true`, closes the drawer when tapped.
  const SecondaryOptionWidget({
    required this.onPressed,
    required this.label,
    required this.icondata,
    this.description = '',
    this.getOutOnTap = false,
    super.key,
  });

  /// Callback function triggered when the option is tapped.
  final VoidCallback onPressed;

  /// The label for the option.
  final String label;

  /// The description for the option, displayed as a subtitle. Default is an empty string.
  final String description;

  /// The icon to display alongside the label.
  final IconData icondata;

  /// If `true`, closes the drawer when tapped. Default is `false`.
  final bool getOutOnTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      iconColor: Theme.of(context).splashColor,
      onTap: () {
        onPressed();
        if (getOutOnTap) {
          Scaffold.of(context).openDrawer();
        }
      },
      title: Text(label),
      leading: Icon(icondata),
      subtitle: description.isNotEmpty ? Text(description) : null,
    );
  }
}
