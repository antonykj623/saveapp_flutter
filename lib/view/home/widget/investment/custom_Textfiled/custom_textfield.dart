import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLines;
  final TextAlign textAlign;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        textAlign: textAlign,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}