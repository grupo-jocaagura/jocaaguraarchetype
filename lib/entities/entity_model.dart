import 'dart:convert';

import 'package:flutter/foundation.dart';

/// [EntityModel]The base class for all entity models in the application.
///
/// All entity models should extend this class and override its methods
/// as needed.
///
/// This class is intended to be abstract and should not be instantiated
/// directly.
@immutable
abstract class EntityModel {
  const EntityModel();

  /// Converts a JSON [Map] to an entity model.
  ///
  /// [json] is the JSON [Map] to be converted to an entity model.
  const EntityModel.fromJson(Map<String, dynamic> json);

  /// [toJson] Converts the entity model to a JSON [Map].
  ///
  /// Returns an empty [Map] by default. Override this method to customize
  /// the JSON conversion for your entity model.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }

  /// [copyWith]Creates a copy of the entity model.
  ///
  /// Returns a new instance of the entity model with the same values changing
  /// some of them.
  EntityModel copyWith();

  /// [fromString]Converts a string to a [Map].
  ///
  /// [source] is the string to be converted to a [Map].
  ///
  /// Returns an empty [Map] by default. Override this method to customize
  /// the conversion of your entity model.
  Map<String, dynamic> fromString(String source) {
    Map<String, dynamic> tmp = <String, dynamic>{};
    try {
      tmp = jsonDecode(source) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return tmp;
  }

  /// [==]Checks whether the given [other] object is equal to this entity model.
  ///
  /// Returns `true` if the [other] object is an instance of [EntityModel]
  /// and has the same values as this entity model, otherwise `false`.
  @override
  bool operator ==(Object other);

  /// Gets the hash code for this entity model.
  @override
  int get hashCode;
}
