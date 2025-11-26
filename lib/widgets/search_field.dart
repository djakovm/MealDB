import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSubmitted;

  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onClear,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
          onPressed: onClear,
          icon: const Icon(Icons.close),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
      ),
    );
  }
}
