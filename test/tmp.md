# Coverage follow-up

- Unable to enumerate coverage (`coverage/lcov.info`) or run `flutter test --coverage` inside the previous PowerShell session; it only printed the shell banner. Now that coverage exists, re-use the generated `lcov` file for guidance.

## Files with uncovered lines (from coverage/lcov.info)
- `lib/ui/widgets/list_tile_exit_drawer_widget.dart`: 159, 161, 162, 174, 198, 218, 219, 220
- `lib/ui/widgets/mobile_secondary_menu_widget.dart`: fully covered
- `lib/ui/widgets/responsive_generator_widget.dart`: (covered after new tests)
- `lib/ui/widgets/projector_widget.dart`: lines pending once tests run
- (See coverage/lcov.info for the complete list; entries without zero-hit lines omitted here.)

## lib/ files lacking *_test.dart counterparts
- (Sample; generate full list if needed)
- `ui/widgets/responsive_generator_widget.dart` (has tests)
- Additional files detected by script require manual mapping.

