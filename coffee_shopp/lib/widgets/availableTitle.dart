import 'package:flutter/cupertino.dart';

class AvailableTitle extends StatelessWidget {

  String text;
  AvailableTitle(this.text);


  @override
  Widget build(BuildContext context) {
    return Text("${text}", style: TextStyle(color: Color.fromRGBO(67, 37, 0, 0.76),fontSize: 18, fontWeight: FontWeight.bold,),);
  }
}
