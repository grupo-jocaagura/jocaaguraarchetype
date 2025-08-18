part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

String? _defaultFunction(String val) {
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
  /// - [onEditingValueFunction]: Function to call when editing is complete.
  /// - [suggestList]: List of suggestions for autocomplete.
  /// - [initialData]: Initial value for the input field.
  /// - [placeholder]: Placeholder text for the input field.
  /// - [onEditingValidateFunction]: Function for validating the input.
  /// - [icondata]: Icon to display as a prefix in the input field.
  /// - [textInputType]: Keyboard type for the input field.
  const CustomAutoCompleteInputWidget({
    required this.onEditingValueFunction,
    super.key,
    this.label = '',
    this.suggestList,
    this.initialData = '',
    this.placeholder = '',
    this.onEditingValidateFunction = _defaultFunction,
    this.icondata,
    this.textInputType = TextInputType.text,
  });

  /// List of suggestions for the autocomplete feature.
  final List<String>? suggestList;

  /// Initial value for the input field.
  final String initialData;

  /// Placeholder text displayed when the input field is empty.
  final String placeholder;

  /// Label text displayed above the input field.
  final String label;

  /// Function called when editing is complete.
  final void Function(String val) onEditingValueFunction;

  /// Function for validating the input value.
  ///
  /// Should return an error message if invalid, or `null` if valid.
  final String? Function(String val) onEditingValidateFunction;

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
  late TextEditingController _controller;
  String? _errorText;
  late String _selectedValue;
  bool _isStarted = false;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialData;
    _controller = TextEditingController(text: _selectedValue);
    _onValidate(_selectedValue);
  }

  /// Validates the input value and updates the error text if necessary.
  void _onValidate(String val) {
    _errorText = widget.onEditingValidateFunction(val);
    if (_errorText == null) {
      widget.onEditingValueFunction(val);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          } else {
            return widget.suggestList?.where(
                  (String word) => word
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()),
                ) ??
                const Iterable<String>.empty();
          }
        },
        optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options,
        ) {
          return Material(
            elevation: 4,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index) {
                final String option = options.elementAt(index);
                return ListTile(
                  title: Text(option),
                  onTap: () {
                    _selectedValue = option;
                    _controller.text = _selectedValue;
                    _onValidate(_selectedValue);
                    onSelected(option);
                    FocusScope.of(context).unfocus();
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemCount: options.length,
            ),
          );
        },
        onSelected: (String selectedString) {
          _controller.text = selectedString;
          _onValidate(selectedString);
          FocusScope.of(context).unfocus();
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController controller,
          FocusNode focusNode,
          void Function() onEditingComplete,
        ) {
          if (_isStarted == false) {
            controller.text = _selectedValue;
            _isStarted = true;
          }
          return TextField(
            keyboardType: widget.textInputType,
            controller: controller,
            focusNode: focusNode,
            onChanged: _onValidate,
            decoration: InputDecoration(
              prefixIcon:
                  widget.icondata != null ? Icon(widget.icondata) : null,
              label: widget.label.isNotEmpty ? Text(widget.label) : null,
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
      ),
    );
  }
}
