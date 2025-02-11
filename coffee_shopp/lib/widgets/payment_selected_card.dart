import 'package:flutter/material.dart';
import '../classes/creditCards.dart';

class PaymentSelectedCard extends StatelessWidget {
  final CreditCards card;

  const PaymentSelectedCard({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[100],
      child: ListTile(
        title: Text('${card.holderName}'),
        subtitle: Text('${card.cardNo}'),
        trailing: Icon(Icons.check_circle, color: Color.fromRGBO(198, 124, 78, 1)),
      ),
    );
  }
}
