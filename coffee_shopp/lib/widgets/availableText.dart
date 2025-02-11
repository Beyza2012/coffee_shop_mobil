import 'package:flutter/cupertino.dart';

class AvailableText extends StatelessWidget {

   String text;
   AvailableText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 15, color: Color.fromRGBO(198, 124, 78, 1),));
  }
}
