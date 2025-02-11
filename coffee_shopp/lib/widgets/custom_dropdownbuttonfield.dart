import 'package:flutter/material.dart';

class CustomDropdownFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final List<String> items;
  final String? Function(String?)? validator;
  final ValueChanged<String?> onChanged;

  const CustomDropdownFormField({
    required this.controller,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.validator,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
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
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (value) {
        controller.text = value ?? ''; // Dropdown'dan seçilen değeri controller'a yansıt
        onChanged(value);
      },
      validator: validator,
    );
  }
}
