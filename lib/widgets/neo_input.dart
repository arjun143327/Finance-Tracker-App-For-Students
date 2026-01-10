import 'package:flutter/material.dart';
import '../theme/neo_colors.dart';

class NeoInput extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;

  const NeoInput({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<NeoInput> createState() => _NeoInputState();
}

class _NeoInputState extends State<NeoInput> {
  bool _obscureText = true;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
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
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 56,
      decoration: BoxDecoration(
        color: NeoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? NeoColors.orange : NeoColors.black,
          width: _isFocused ? 4 : 3,
        ),
        boxShadow: [
          BoxShadow(
            color: NeoColors.black.withOpacity(0.1),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
          // Focus glow
          if (_isFocused)
            BoxShadow(
              color: NeoColors.orange.withOpacity(0.2),
              blurRadius: 0,
              spreadRadius: 4,
            ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.isPassword ? _obscureText : false,
          style: const TextStyle(
            color: NeoColors.darkGray,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: NeoColors.gray, fontWeight: FontWeight.w500),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: _isFocused ? NeoColors.orange : NeoColors.gray)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: NeoColors.darkGray,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
