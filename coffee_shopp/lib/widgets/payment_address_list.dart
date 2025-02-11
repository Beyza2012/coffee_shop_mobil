import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shopp/classes/Adresses.dart';
import 'package:coffee_shopp/service/adressesProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'availableTitle.dart';

class PaymentAddressList extends StatelessWidget {
  final List<Adresses> adresses ;
  const PaymentAddressList({Key? key, required this.adresses}) : super(key: key);
  Future<void> selectedAdress(String cardId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final collectionRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Adresses');

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
              itemCount: adresses.length,
              itemBuilder: (context, index) {
                final adress = adresses[index];
                return GestureDetector(
                  onTap: () async {
                    await selectedAdress("${adress.id}"); // Seçilen kartı güncelle
                    Provider.of<AdressesProvider>(context, listen: false).setSelectedAdress(adress);
                    Navigator.pop(context); // Modal'ı kapat
                  },
                  child: Card(
                    color: (adress.selected ?? false) ? Colors.orange[100] : Colors.white,
                    child: ListTile(
                      title: Text('${adress.addressLine}'),
                      subtitle: Text('${adress.city}'),
                      trailing: (adress.selected ?? false)
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
