import 'package:coffee_shopp/classes/Adresses.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentSelectedAdress extends StatelessWidget {
  final Adresses adress;
  const PaymentSelectedAdress({Key? key, required this.adress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[100],
      child: ListTile(
        title: Text('${adress.city}'),
        subtitle: Text('${adress.title}'),
        trailing: Icon(Icons.check_circle, color: Color.fromRGBO(198, 124, 78, 1)),
      ),
    );
  }
}
