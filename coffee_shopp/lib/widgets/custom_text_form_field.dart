import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final bool obscureText;

  const CustomTextFormField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.validator,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(235, 212, 212, 100),
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(198, 124, 78, 1),
          ),
        ),
        errorStyle: TextStyle(
          color: Color.fromRGBO(198, 124, 78, 1),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(198, 124, 78, 1),
          ),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(198, 124, 78, 1), // Hata durumunda odaklanılmış alt çizgi rengi kırmızı
          ),
        ),
      ),
      validator: validator,
    );
  }
}
