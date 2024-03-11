import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/entities/entity_model.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('EntityModel', () {
    test('toJson returns a valid JSON from EntityModel', () {
      const MockEntityModel entityModel = MockEntityModel();
      final Map<String, dynamic> result = entityModel.toJson();
      expect(result, equals(<String, dynamic>{}));
    });

    test('fromJson returns empty map when source is not valid json', () {
      const MockEntityModel entityModel = MockEntityModel();
      final Map<String, dynamic> result =
          entityModel.fromString('invalid_json');
      expect(result, <String, dynamic>{});
    });
    test('fromJson returns parsed json when source is valid json', () {
      const MockEntityModel entityModel = MockEntityModel();
      final Map<String, dynamic> result =
          entityModel.fromString('{ "name": "John", "age": 30 }');
      expect(result, <String, dynamic>{'name': 'John', 'age': 30});
      final MockEntityModel result2 = MockEntityModel.fromJson(result);
      expect(result2.runtimeType == MockEntityModel, true);
      expect(result2 == entityModel, true);
    });
    test('copyWith returns same model no matter what', () {
      const MockEntityModel entityModel = MockEntityModel();
      final EntityModel result = entityModel.copyWith();
      expect(result.hashCode, entityModel.hashCode);
    });
    test('test the bool == operator', () {
      const MockEntityModel entityModel = MockEntityModel();
      const MockEntityModel result = MockEntityModel();
      expect(result, equals(entityModel));
      expect(result == entityModel, equals(true));
      expect(result.hashCode, equals(entityModel.hashCode));
    });
  });
}

class MockEntityModel extends EntityModel {
  const MockEntityModel();

  const MockEntityModel.fromJson(Map<String, dynamic> result);
  @override
  EntityModel copyWith() {
    return this;
  }

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType;
  }

  @override
  int get hashCode {
    return 1;
  }
}
