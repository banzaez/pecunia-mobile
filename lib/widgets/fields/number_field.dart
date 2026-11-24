import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:pecunia/widgets/fields/base_field.dart';

class NumberField extends StatelessWidget {
  final NumberEditingController? controller;
  final ValueChanged<num>? onChanged;
  final bool autofocus;
  final num? initialValue;
  final String? hintText;
  final String? labelText;
  final String? suffixText;
  final String? errorText;
  final bool enabled;
  final bool showLabel;
  final int decimal;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const NumberField({
    super.key,
    this.controller,
    this.onChanged,
    this.autofocus = false,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.suffixText,
    this.errorText,
    this.enabled = true,
    this.showLabel = true,
    this.decimal = 2,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) => BaseField(
    controller: controller,
    initialValue: initialValue?.toString(),
    autofocus: autofocus,
    enabled: enabled,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(
        RegExp(
          r'(^\d*[\.,]?\d{0,'
          '$decimal})',
        ),
      ),
    ],
    hintText: hintText,
    showLabel: showLabel,
    labelText: labelText,
    suffixText: suffixText,
    errorText: errorText,
    validator: validator,
    textInputAction: textInputAction,
    onFieldSubmitted: onFieldSubmitted,
    onChanged: (value) =>
        onChanged?.call(num.tryParse(value.replaceAll(",", ".")) ?? 0),
  );
}

class NumberEditingController extends TextEditingController {
  num get number => num.tryParse(super.text.replaceAll(",", ".")) ?? 0;

  set number(num? value) => (value == null || value == 0)
      ? super.clear()
      : super.text = value.toString();
}
