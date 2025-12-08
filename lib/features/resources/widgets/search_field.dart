import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/services/get.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showClearButton;

  const SearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
    this.showClearButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.search_rounded, color: Get.disabledColor),
        suffixIcon: showClearButton
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: Get.scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16).rt,
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.zero,
      ),
      textInputAction: TextInputAction.search,
    );
  }
}

