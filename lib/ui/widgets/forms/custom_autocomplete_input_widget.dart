import 'package:flutter/material.dart';

String? _defaultFunction(String val) {
  return null;
}

/// A custom autocomplete input widget.
///
/// This widget provides an input field with autocomplete suggestions.
/// It allows the user to select from a list of suggestions based on the
/// entered text. The suggestions are provided through the [suggestList] parameter.
///
/// Example usage:
/// ```dart
/// CustomAutoCompleteInputWidget(
///   onEditingValueFunction: (String val) {
///     // Handle the value when editing is done
///   },
///   suggestList: ['Apple', 'Banana', 'Orange'],
///   initialData: '',
///   placeholder: 'Enter a fruit',
///   onEditingValidateFunction: (String val) {
///     // Perform validation and return an error message if invalid
///     // Return null if the value is valid
///   },
///   icondata: Icons.fruit_basket,
///   textInputType: TextInputType.text,
/// )
/// ```
class CustomAutoCompleteInputWidget extends StatefulWidget {
  /// Creates a [CustomAutoCompleteInputWidget].
  ///
  /// The [onEditingValueFunction] parameter is required and specifies the function
  /// to be called when editing is complete.
  ///
  /// The [suggestList] parameter is optional and provides a list of suggestions
  /// for autocomplete. If not provided, no autocomplete suggestions will be shown.
  ///
  /// The [initialData] parameter specifies the initial value for the input field.
  ///
  /// The [placeholder] parameter specifies the placeholder text to be displayed
  /// when the input field is empty.
  ///
  /// The [onEditingValidateFunction] parameter is optional and specifies a function
  /// to perform validation on the input value. It takes the input value as a parameter
  /// and should return an error message as a string if the value is invalid, or null
  /// if the value is valid.
  ///
  /// The [icondata] parameter is optional and specifies the icon to be displayed
  /// as a prefix in the input field.
  ///
  /// The [textInputType] parameter specifies the type of keyboard input to be
  /// displayed for the input field.
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

  /// The list of suggestions for autocomplete.
  final List<String>? suggestList;

  /// The initial value for the input field.
  final String initialData;

  /// The placeholder text to be displayed when the input field is empty.
  final String placeholder;

  /// The label text to be displayed above the input field.
  final String label;

  /// The function to be called when editing is complete.
  final void Function(String val) onEditingValueFunction;

  /// The function to perform validation on the input value.
  final String? Function(String val) onEditingValidateFunction;

  /// The icon to be displayed as a prefix in the input field.
  final IconData? icondata;

  /// The type of keyboard input to be displayed for the input field.
  final TextInputType textInputType;

  @override
  CustomAutoCompleteInputWidgetState createState() =>
      CustomAutoCompleteInputWidgetState();
}

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
