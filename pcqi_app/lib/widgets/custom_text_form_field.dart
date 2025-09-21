import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final InputDecoration? inputDecoration;
  final TextStyle? style;
  final List<TextInputFormatter>? textInputFormatter;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final IconButton? prefixIcon;
  final IconButton? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool? obscureText;
  final void Function(String?)? onFieldSubmitted;

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.focusNode,
    this.textInputType,
    this.textInputAction,
    this.inputDecoration,
    this.style,
    this.textInputFormatter,
    this.maxLength,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.obscureText,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: textInputType,
      autofillHints: autofillHints,
      maxLength: maxLength,
      inputFormatters: textInputFormatter,
      buildCounter:
          (
            BuildContext context, {
            int? currentLength,
            int? maxLength,
            bool? isFocused,
          }) => null,
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      decoration: inputDecoration,
      validator: validator,
      onChanged: onChanged,
      style: style,
    );
  }
}
