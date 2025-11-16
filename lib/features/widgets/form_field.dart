import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:krishi/core/services/get.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    this.toHide = false,
    this.controller,
    this.hintText,
    this.hintTextStyle,
    this.textInputType,
    this.inputFormatters,
    this.icon,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.maxLine = 1,
    this.suffixIcon,
    this.autofocus = false,
    this.readOnly = false,
    this.maxCharacter,
    this.title,
    this.fillColor,
    this.direction,
    this.suggestions,
    this.contentPadding,
    this.node,
    this.height,
    this.isDense = false,
    this.radius = 13,
    this.onSelected,
    this.onSubmitted,
    this.isSearchField = false,
    this.onClear,
  });

  final bool toHide;
  final TextEditingController? controller;
  final String? hintText;
  final TextStyle? hintTextStyle;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? icon;
  final Widget? prefixIcon;
  final bool autofocus;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;
  final int? maxLine;
  final dynamic Function(String)? onChanged;
  final bool readOnly;
  final Widget? suffixIcon;
  final int? maxCharacter;
  final String? title;
  final Color? fillColor;
  final TextDirection? direction;
  final EdgeInsetsGeometry? contentPadding;
  final double radius;
  final double? height;
  final bool isDense;
  final FocusNode? node;
  final List<String>? suggestions;
  final dynamic Function(String)? onSubmitted;
  final dynamic Function(String)? onSelected;
  final bool isSearchField;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final inputCharacterLength = ValueNotifier(
      controller != null ? controller!.text.length : 0,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 50,
        height: height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 4,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(title!),
                    ),
                  ),
                const Spacer(),
                if (maxCharacter != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 4,
                    ),
                    child: ValueListenableBuilder<int>(
                      valueListenable: inputCharacterLength,
                      builder: (context, length, child) => Align(
                        alignment: Alignment.centerRight,
                        child: Text('$length/$maxCharacter'),
                      ),
                    ),
                  ),
              ],
            ),
            TextFormField(
              controller: controller,
              obscureText: toHide,
              keyboardType: textInputType,
              inputFormatters: inputFormatters,
              autofocus: autofocus,
              readOnly: readOnly,
              maxLines: maxLine,
              decoration: InputDecoration(
                prefixIcon: isSearchField
                    ? Icon(
                        Icons.search,
                        color: Get.disabledColor.withValues(alpha: 0.5),
                        size: 20,
                      )
                    : prefixIcon,

                suffixIcon:
                    isSearchField &&
                        controller != null &&
                        controller!.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          controller!.clear();
                          if (onClear != null) onClear!();
                        },
                        child: Icon(
                          Icons.clear,
                          color: Get.disabledColor.withValues(alpha: 0.5),
                          size: 20,
                        ),
                      )
                    : suffixIcon,

                hintText: hintText,
                hintStyle: hintTextStyle,
                icon: icon,

                fillColor: fillColor,
                filled: fillColor != null,
                contentPadding: contentPadding,
                isDense: isDense,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              focusNode: node,
              validator: validator,
              onChanged: (text) {
                if (onChanged != null) onChanged!(text);
                inputCharacterLength.value = text.length;
              },
              onFieldSubmitted: onSubmitted,
            ),
          ],
        ),
      ),
    );
  }
}
