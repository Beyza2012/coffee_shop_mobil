import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shopp/service/creditCardsProvider.dart';
import 'package:coffee_shopp/widgets/availableTitle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/creditCards.dart';

class PaymentCardList extends StatelessWidget {
  final List<CreditCards> creditCards;

  const PaymentCardList({Key? key, required this.creditCards}) : super(key: key);

  Future<void> selectCard(String cardId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final collectionRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('CreditCard');

    final batch = FirebaseFirestore.instance.batch();
    final querySnapshot = await collectionRef.get();

    // Önce tüm kartları seçili değil yap
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'selected': false});
    }

    // Seçilen kartı aktif hale getir
    batch.update(collectionRef.doc(cardId), {'selected': true});

    await batch.commit();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AvailableTitle("Kart Seç"),
          SizedBox(height: 10),
          SizedBox(
            height: 200, // ListView yükseklik sınırı
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: creditCards.length,
              itemBuilder: (context, index) {
                final card = creditCards[index];
                return GestureDetector(
                  onTap: () async {
                    await selectCard("${card.id}"); // Seçilen kartı güncelle
                    Provider.of<CreditCardProvider>(context, listen: false).setSelectedCard(card);
                    Navigator.pop(context); // Modal'ı kapat
                  },
                  child: Card(
                    color: (card.selected ?? false) ? Colors.orange[100] : Colors.white,
                    child: ListTile(
                      title: Text('${card.holderName}'),
                      subtitle: Text('${card.cardNo}'),
                      trailing: (card.selected ?? false)
                          ? Icon(Icons.check_circle, color: Color.fromRGBO(198, 124, 78, 1))
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
