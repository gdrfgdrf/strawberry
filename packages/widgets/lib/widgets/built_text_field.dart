import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:shared/l10n/localizer.dart';
import 'package:shared/themes.dart';

enum TextFieldType { normal, password }

abstract class AbstractTextFieldTemplate {
  void apply(TextFieldBuilder builder, BuildContext context);
}

class TextFieldBuilder {
  TextInputType? _type;
  TextInputAction? _action;

  int _maxLines = 1;
  int _minLines = 1;

  String? _hint;
  String? _label;

  ValueChanged<String>? _onChanged;
  FormFieldValidator<String>? _validator;
  TextEditingController? _controller;

  Widget? _icon;
  Widget? _suffixIcon;

  TextStyle? _style;
  TextAlign? _align;

  bool _obscure = false;
  bool _enabled = true;

  TextFieldBuilder.newBuilder();

  TextFieldBuilder typeOf(TextInputType type) {
    _type = type;
    return this;
  }

  TextFieldBuilder actionOf(TextInputAction action) {
    _action = action;
    return this;
  }

  TextFieldBuilder maxLinesOf(int maxLines) {
    _maxLines = maxLines;
    return this;
  }

  TextFieldBuilder minLinesOf(int minLines) {
    _minLines = minLines;
    return this;
  }

  TextFieldBuilder hintOf(String hint) {
    _hint = hint;
    return this;
  }

  TextFieldBuilder labelOf(String label) {
    _label = label;
    return this;
  }

  TextFieldBuilder onChangedOf(ValueChanged<String> onChanged) {
    _onChanged = onChanged;
    return this;
  }

  TextFieldBuilder validatorOf(FormFieldValidator<String> validator) {
    _validator = validator;
    return this;
  }

  TextFieldBuilder controllerOf(TextEditingController controller) {
    _controller = controller;
    return this;
  }

  TextFieldBuilder iconOf(Widget icon) {
    _icon = icon;
    return this;
  }

  TextFieldBuilder suffixIconOf(Widget suffixIcon) {
    _suffixIcon = suffixIcon;
    return this;
  }

  TextFieldBuilder styleOf(TextStyle style) {
    _style = style;
    return this;
  }

  TextFieldBuilder alignOf(TextAlign align) {
    _align = align;
    return this;
  }

  TextFieldBuilder obscureOf(bool obscure) {
    _obscure = obscure;
    return this;
  }

  TextFieldBuilder enabledOf(bool enabled) {
    _enabled = enabled;
    return this;
  }

  TextFieldBuilder normal(BuildContext context) {
    template(_NormalTextFieldTemplate(), context);
    return this;
  }

  TextFieldBuilder password(BuildContext context) {
    template(_PasswordTextFieldTemplate(), context);
    return this;
  }

  TextFieldBuilder template(
    AbstractTextFieldTemplate template,
    BuildContext context,
  ) {
    template.apply(this, context);
    return this;
  }

  BuiltTextField buildNormal() {
    return build(TextFieldType.normal);
  }

  BuiltTextField buildPassword() {
    return build(TextFieldType.password);
  }

  BuiltTextField build(TextFieldType fieldType) {
    return BuiltTextField(
      fieldType: fieldType,
      type: _type,
      hint: _hint,
      action: _action,
      icon: _icon,
      onChanged: _onChanged,
      enabled: _enabled,
      obscure: _obscure,
      style: _style,
      label: _label,
      validator: _validator,
      controller: _controller,
      suffixIcon: _suffixIcon,
      minLines: _minLines,
      maxLines: _maxLines,
      align: _align,
    );
  }
}

class BuiltTextField extends StatefulWidget {
  final TextFieldType fieldType;
  TextInputType? type;
  TextInputAction? action;

  int minLines;
  int maxLines;

  String? hint;
  String? label;

  ValueChanged<String>? onChanged;
  FormFieldValidator<String>? validator;
  TextEditingController? controller;

  Widget? icon;
  Widget? suffixIcon;

  TextStyle? style;
  TextAlign align;

  bool obscure;
  bool enabled;

  BuiltTextField({
    super.key,
    TextFieldType? fieldType,
    this.type,
    this.action,
    int? minLines,
    int? maxLines,
    this.hint,
    this.label,
    this.onChanged,
    this.validator,
    this.controller,
    this.icon,
    this.suffixIcon,
    this.style,
    TextAlign? align,
    bool? obscure,
    bool? enabled,
  }) : fieldType = fieldType ?? TextFieldType.normal,
       minLines = minLines ?? 1,
       maxLines = maxLines ?? 1,
       align = align ?? TextAlign.start,
       obscure = obscure ?? false,
       enabled = enabled ?? true;

  @override
  State<StatefulWidget> createState() => _BuiltTextFieldState();
}

class _BuiltTextFieldState extends State<BuiltTextField> {
  IconData? _suffixIconData;
  bool _obscure = false;

  void _toggleVisibility() {
    setState(() {
      _obscure = !_obscure;
      _suffixIconData = _obscure ? Icons.visibility_off : Icons.visibility;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.fieldType == TextFieldType.password) {
      _obscure = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? actualSuffixIcon = widget.suffixIcon;

    if (widget.fieldType == TextFieldType.password) {
      actualSuffixIcon = IconButton(
        onPressed: () {
          _toggleVisibility();
        },
        icon: Icon(_suffixIconData ?? Icons.visibility_off),
      );
    }

    final textField = MaterialTextField(
      keyboardType: widget.type,
      textInputAction: widget.action,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      hint: widget.hint,
      labelText: widget.label,
      onChanged: widget.onChanged,
      validator: widget.validator,
      controller: widget.controller,
      icon: widget.icon,
      suffixIcon:
          widget.fieldType == TextFieldType.password ? null : actualSuffixIcon,
      style: widget.style,
      textAlign: widget.align,
      obscureText: _obscure,
      enabled: widget.enabled,
      theme: FilledOrOutlinedTextTheme(
        radius: 16,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        fillColor: themeData().colorScheme.surfaceContainer,
      ),
    );

    return Stack(
      children: [
        textField,
        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: actualSuffixIcon ?? SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _NormalTextFieldTemplate extends AbstractTextFieldTemplate {
  static _NormalTextFieldTemplate? _instance;

  _NormalTextFieldTemplate._() {
    _instance = this;
  }

  factory _NormalTextFieldTemplate() =>
      _instance ?? _NormalTextFieldTemplate._();

  @override
  void apply(TextFieldBuilder builder, BuildContext context) {
    builder.typeOf(TextInputType.text);
  }
}

class _PasswordTextFieldTemplate extends AbstractTextFieldTemplate {
  static _PasswordTextFieldTemplate? _instance;

  _PasswordTextFieldTemplate._() {
    _instance = this;
  }

  factory _PasswordTextFieldTemplate() =>
      _instance ?? _PasswordTextFieldTemplate._();

  @override
  void apply(TextFieldBuilder builder, BuildContext context) {
    builder
        .typeOf(TextInputType.visiblePassword)
        .hintOf(Localizer.of(context)!.password_here)
        .obscureOf(true);
  }
}
