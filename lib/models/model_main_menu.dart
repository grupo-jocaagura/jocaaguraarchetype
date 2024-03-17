// ignore_for_file: require_trailing_commas

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

class ModelMainMenu extends Model {
  const ModelMainMenu(
      {required this.iconData,
      required this.onPressed,
      required this.label,
      this.description = ''});

  final IconData iconData;
  final void Function() onPressed;
  final String label;
  final String description;

  @override
  ModelMainMenu copyWith({
    IconData? iconData,
    void Function()? onPressed,
    String? label,
    String? description,
  }) {
    return ModelMainMenu(
        iconData: iconData ?? this.iconData,
        onPressed: onPressed ?? this.onPressed,
        label: label ?? this.label,
        description: description ?? this.description);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelMainMenu &&
          runtimeType == other.runtimeType &&
          iconData == other.iconData &&
          label == other.label &&
          description == other.description &&
          hashCode == other.hashCode;

  @override
  int get hashCode => label.toLowerCase().hashCode;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }
}
