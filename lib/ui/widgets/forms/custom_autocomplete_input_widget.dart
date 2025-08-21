part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

String? _defaultFunction(String? val) {
  return null;
}

/// A customizable widget for text input with autocomplete functionality.
///
/// The `CustomAutoCompleteInputWidget` provides an input field that suggests
/// autocomplete options as the user types. It supports custom validation, input types,
/// and placeholder text, making it versatile for various use cases.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/custom_autocomplete_input_widget.dart';
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
///         appBar: AppBar(title: Text('Custom Autocomplete Input')),
///         body: Padding(
///           padding: const EdgeInsets.all(16.0),
///           child: CustomAutoCompleteInputWidget(
///             suggestList: ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'],
///             placeholder: 'Type a fruit name',
///             onEditingValueFunction: (value) {
///               print('Input Value: $value');
///             },
///             onEditingValidateFunction: (value) {
///               if (value.isEmpty) return 'This field cannot be empty';
///               if (!['apple', 'banana', 'cherry', 'date', 'elderberry']
///                   .contains(value.toLowerCase())) {
///                 return 'Invalid fruit name';
///               }
///               return null;
///             },
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class CustomAutoCompleteInputWidget extends StatefulWidget {
  /// Creates a `CustomAutoCompleteInputWidget`.
  ///
  /// - [onChanged]: Function to call when editing is complete.
  /// - [suggestList]: List of suggestions for autocomplete.
  /// - [initialData]: Initial value for the input field.
  /// - [placeholder]: Placeholder text for the input field.
  /// - [onEditingValidateFunction]: Function for validating the input.
  /// - [icondata]: Icon to display as a prefix in the input field.
  /// - [textInputType]: Keyboard type for the input field.
  const CustomAutoCompleteInputWidget({
    required this.onChanged,
    super.key,
    this.label = '',
    this.suggestList,
    this.initialData = '',
    this.placeholder = '',
    this.onEditingValidateFunction = _defaultFunction,
    this.onFieldSubmitted = _defaultFunction,
    this.icondata,
    this.textInputType = TextInputType.text,
    this.onChangedDebounce,
  });

  /// Debounce time applied to onChanged validations.
  /// If null, validates on every keystroke.
  final Duration? onChangedDebounce;

  /// List of suggestions for the autocomplete feature.
  final List<String>? suggestList;

  /// Initial value for the input field.
  final String initialData;

  /// Placeholder text displayed when the input field is empty.
  final String placeholder;

  /// Label text displayed above the input field.
  final String label;

  /// Function called when editing is complete.
  final void Function(String val) onChanged;

  /// Function called when editing is complete.
  final void Function(String val) onFieldSubmitted;

  /// Function for validating the input value.
  ///
  /// Should return an error message if invalid, or `null` if valid.
  final String? Function(String? val) onEditingValidateFunction;

  /// Icon displayed as a prefix in the input field.
  final IconData? icondata;

  /// Keyboard type for the input field.
  final TextInputType textInputType;

  @override
  CustomAutoCompleteInputWidgetState createState() =>
      CustomAutoCompleteInputWidgetState();
}

/// State class for `CustomAutoCompleteInputWidget`.
class CustomAutoCompleteInputWidgetState
    extends State<CustomAutoCompleteInputWidget> {
  String? _errorText;
  late String _selectedValue;
  Timer? _debounce; // NEW

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialData;
    _onValidate(_selectedValue);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Validates the input value and updates the error text if necessary.
  void _onValidate(String val) {
    _errorText = widget.onEditingValidateFunction(val);
    if (_errorText == null) {
      widget.onChanged(val);
    }
    setState(() {});
  }

  void _onChangedWithOptionalDebounce(String val) {
    if (widget.onChangedDebounce != null) {
      _debounce?.cancel();
      _debounce = Timer(widget.onChangedDebounce!, () => _onValidate(val));
      return;
    } else {
      _onValidate(val);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: widget.initialData),
      optionsBuilder: (TextEditingValue tev) {
        if (tev.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        final Iterable<String> base = widget.suggestList ?? const <String>[];
        final String q = tev.text.toLowerCase();
        return base.where((String s) => s.toLowerCase().contains(q));
      },
      optionsViewBuilder:
          (_, void Function(String) onSelected, Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, minWidth: 280),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, int i) {
                  final String option = options.elementAt(i);
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      onSelected(
                        option,
                      ); // Autocomplete sincroniza el controller
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: (String val) {
        _onValidate(val);
        FocusScope.of(context).unfocus();
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController controller,
        FocusNode focusNode,
        void Function() onEditingComplete,
      ) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: widget.textInputType,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          autocorrect: true,
          onChanged: _onChangedWithOptionalDebounce,
          onEditingComplete: () {
            final String v = controller.text;
            _errorText = widget.onEditingValidateFunction(v);
            if (_errorText == null) {
              widget.onFieldSubmitted(v);
            }
            setState(() {});
            onEditingComplete();
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            prefixIcon: widget.icondata != null ? Icon(widget.icondata) : null,
            label: widget.label.isNotEmpty ? Text(widget.label) : null,
            hintText: widget.placeholder,
            errorText: _errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange),
            ),
          ),
        );
      },
    );
  }
}
