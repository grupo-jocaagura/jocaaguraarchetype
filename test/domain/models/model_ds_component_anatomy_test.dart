import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ModelDsComponentLink', () {
    test('Given valid json When fromJson Then parses and toJson round-trips',
        () {
      final Map<String, dynamic> json = <String, dynamic>{
        ModelDsComponentLinkKeys.label: 'Guidelines',
        ModelDsComponentLinkKeys.url: 'https://internal/wiki',
      };

      final ModelDsComponentLink link = ModelDsComponentLink.fromJson(json);
      expect(link.label, 'Guidelines');
      expect(link.url, 'https://internal/wiki');

      expect(ModelDsComponentLink.fromJson(link.toJson()), equals(link));
      expect(
        ModelDsComponentLink.fromJson(link.toJson()).hashCode,
        link.hashCode,
      );
    });

    test('Given invalid label When fromJson Then throws FormatException', () {
      expect(
        () => ModelDsComponentLink.fromJson(const <String, dynamic>{
          ModelDsComponentLinkKeys.label: '   ',
          ModelDsComponentLinkKeys.url: 'x',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('Given invalid url When fromJson Then throws FormatException', () {
      expect(
        () => ModelDsComponentLink.fromJson(const <String, dynamic>{
          ModelDsComponentLinkKeys.label: 'a',
          ModelDsComponentLinkKeys.url: '   ',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ModelDsComponentSlot', () {
    Map<String, dynamic> validSlotJson() => <String, dynamic>{
          ModelDsComponentSlotKeys.name: 'Container',
          ModelDsComponentSlotKeys.role: 'Surface and shape',
          ModelDsComponentSlotKeys.rules: <dynamic>['Uses DS radius tokens'],
          ModelDsComponentSlotKeys.tokensUsed: <dynamic>[
            'borderRadius',
            'spacingSm',
          ],
        };

    test('Given valid json When fromJson Then parses and toJson round-trips',
        () {
      final ModelDsComponentSlot slot =
          ModelDsComponentSlot.fromJson(validSlotJson());

      expect(slot.name, 'Container');
      expect(slot.role, 'Surface and shape');
      expect(slot.rules, <String>['Uses DS radius tokens']);
      expect(slot.tokensUsed, <String>['borderRadius', 'spacingSm']);

      final ModelDsComponentSlot restored =
          ModelDsComponentSlot.fromJson(slot.toJson());
      expect(restored, equals(slot));
      expect(restored.hashCode, equals(slot.hashCode));
    });

    test('Given missing rules list When fromJson Then throws FormatException',
        () {
      final Map<String, dynamic> json = validSlotJson();
      json[ModelDsComponentSlotKeys.rules] = 'nope';

      expect(
        () => ModelDsComponentSlot.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('Given empty tokensUsed When fromJson Then throws FormatException',
        () {
      final Map<String, dynamic> json = validSlotJson();
      json[ModelDsComponentSlotKeys.tokensUsed] = <dynamic>[];

      expect(
        () => ModelDsComponentSlot.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test(
        'Given rules contains empty string When fromJson Then throws FormatException',
        () {
      final Map<String, dynamic> json = validSlotJson();
      json[ModelDsComponentSlotKeys.rules] = <dynamic>['ok', '   '];

      expect(
        () => ModelDsComponentSlot.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ModelDsComponentAnatomy', () {
    Map<String, dynamic> validAnatomyJson({
      Object? links,
      Object? previewAssetKey,
      Object? previewUrlImage,
      Object? urlDetailedInfo,
      Object? platforms,
      Object? slots,
    }) {
      return <String, dynamic>{
        ModelDsComponentAnatomyKeys.id: 'ds.button',
        ModelDsComponentAnatomyKeys.name: 'Buttons',
        ModelDsComponentAnatomyKeys.description:
            'Triggers an action with consistent styling.',
        ModelDsComponentAnatomyKeys.tags: <dynamic>['action', 'input'],
        ModelDsComponentAnatomyKeys.status:
            ModelDsComponentStatusEnum.stable.name,
        ModelDsComponentAnatomyKeys.platforms: platforms ??
            <dynamic>[
              ModelDsComponentPlatformEnum.android.name,
              ModelDsComponentPlatformEnum.ios.name,
              ModelDsComponentPlatformEnum.web.name,
            ],
        ModelDsComponentAnatomyKeys.previewAssetKey: previewAssetKey,
        ModelDsComponentAnatomyKeys.previewUrlImage: previewUrlImage,
        ModelDsComponentAnatomyKeys.urlDetailedInfo: urlDetailedInfo,
        ModelDsComponentAnatomyKeys.links: links,
        ModelDsComponentAnatomyKeys.slots: slots ??
            <dynamic>[
              <String, dynamic>{
                ModelDsComponentSlotKeys.name: 'Container',
                ModelDsComponentSlotKeys.role: 'Surface and shape',
                ModelDsComponentSlotKeys.rules: <dynamic>[
                  'Uses DS radius tokens',
                ],
                ModelDsComponentSlotKeys.tokensUsed: <dynamic>[
                  'borderRadius',
                  'spacingSm',
                ],
              },
            ],
      };
    }

    test('Given valid json When fromJson Then parses and toJson round-trips',
        () {
      final ModelDsComponentAnatomy a = ModelDsComponentAnatomy.fromJson(
        validAnatomyJson(
          links: <dynamic>[
            <String, dynamic>{
              ModelDsComponentLinkKeys.label: 'Guidelines',
              ModelDsComponentLinkKeys.url: 'https://internal/wiki',
            }
          ],
        ),
      );

      expect(a.id, 'ds.button');
      expect(a.tags, isNotEmpty);
      expect(a.platforms, isNotEmpty);
      expect(a.slots, isNotEmpty);
      expect(a.links.length, 1);

      final ModelDsComponentAnatomy restored =
          ModelDsComponentAnatomy.fromJson(a.toJson());

      expect(restored.id, a.id);
      expect(restored.name, a.name);
      expect(restored.description, a.description);
      expect(restored.tags, a.tags);
      expect(restored.status, a.status);

      // Compare enum lists by content (order preserved)
      expect(restored.platforms, a.platforms);

      // Compare nested lists by content
      expect(restored.links, a.links);
      expect(restored.slots, a.slots);
    });

    test('Given links is null When fromJson Then links becomes empty list', () {
      final ModelDsComponentAnatomy a =
          ModelDsComponentAnatomy.fromJson(validAnatomyJson());
      expect(a.links, isEmpty);
    });

    test('Given optional strings are empty When fromJson Then become null', () {
      final ModelDsComponentAnatomy a = ModelDsComponentAnatomy.fromJson(
        validAnatomyJson(
          previewAssetKey: '   ',
          previewUrlImage: '',
          urlDetailedInfo: '  ',
        ),
      );

      expect(a.previewAssetKey, isNull);
      expect(a.previewUrlImage, isNull);
      expect(a.urlDetailedInfo, isNull);
    });

    test('Given unknown status When fromJson Then throws FormatException', () {
      final Map<String, dynamic> json = validAnatomyJson();
      json[ModelDsComponentAnatomyKeys.status] = 'unknown_status';

      expect(
        () => ModelDsComponentAnatomy.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('Given unknown platform When fromJson Then throws FormatException',
        () {
      final Map<String, dynamic> json = validAnatomyJson(
        platforms: <dynamic>['android', 'unknown_platform'],
      );

      expect(
        () => ModelDsComponentAnatomy.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('Given empty platforms When fromJson Then throws FormatException', () {
      final Map<String, dynamic> json =
          validAnatomyJson(platforms: <dynamic>[]);

      expect(
        () => ModelDsComponentAnatomy.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test(
        'Given slots is missing or invalid type When fromJson Then throws FormatException',
        () {
      final Map<String, dynamic> json = validAnatomyJson();
      json[ModelDsComponentAnatomyKeys.slots] = 'nope';

      expect(
        () => ModelDsComponentAnatomy.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('Given slots empty list When fromJson Then throws FormatException',
        () {
      final Map<String, dynamic> json = validAnatomyJson(slots: <dynamic>[]);

      expect(
        () => ModelDsComponentAnatomy.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test(
        'Given tags contains empty string When fromJson Then throws FormatException',
        () {
      final Map<String, dynamic> json = validAnatomyJson();
      json[ModelDsComponentAnatomyKeys.tags] = <dynamic>['ok', '   '];

      expect(
        () => ModelDsComponentAnatomy.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('Given invalid link entry When fromJson Then throws FormatException',
        () {
      final Map<String, dynamic> json = validAnatomyJson(
        links: <dynamic>['nope'],
      );

      expect(
        () => ModelDsComponentAnatomy.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
