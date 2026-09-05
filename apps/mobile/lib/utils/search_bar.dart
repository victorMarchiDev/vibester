import 'package:flutter/material.dart';
import 'package:mobile/theme/app_motion.dart';
import 'package:mobile/theme/theme_extensions.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback? onSubmitted;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onSubmitted,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: context.adaptiveMotion(AppMotion.normal),
      curve: AppMotion.standard,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.noturno,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focused
              ? context.colors.ambar
              : Colors.white.withOpacity(0.12),
          width: 2,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        cursorColor: context.colors.ambar,
        style: context.typography.bodyLarge.copyWith(color: Colors.white),
        onChanged: (_) => widget.onChanged(),
        onSubmitted: (_) => widget.onSubmitted?.call(),
        decoration: InputDecoration(
          hintText: 'Buscar por nome ou categoria...',
          hintStyle: context.typography.bodyMedium.copyWith(
            color: Colors.white38,
          ),
          prefixIcon: Icon(Icons.search, color: context.colors.ambar),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: Colors.white38),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
