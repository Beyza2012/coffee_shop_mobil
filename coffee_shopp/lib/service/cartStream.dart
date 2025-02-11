import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class CartStream with ChangeNotifier{

  final currentUser = FirebaseAuth.instance.currentUser;
  Future<void> addToCart({required String coffeeId}) async {

    final cartRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser?.uid)
        .collection('Cart');
    final existingCartItem = await cartRef.where('coffeeId', isEqualTo: coffeeId).get();
    if (existingCartItem.docs.isNotEmpty) {
      // Kahve zaten sepette varsa, miktarını artır
      final cartItemId = existingCartItem.docs.first.id;
      final currentQuantity = existingCartItem.docs.first['quantity'];
      await cartRef.doc(cartItemId).update({
        'quantity': currentQuantity + 1,
      });
    } else {
      // Kahve sepette yoksa, yeni belge ekle
      await cartRef.add({
        'coffeeId': coffeeId,
        'quantity': 1,
      });
    }
  }
  Future <void> deleteCartItem(String coffeeId) async {
    try {
      // Kullanıcıya ait Cart koleksiyonundan coffeeId ile eşleşen tüm öğeleri al
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.uid)
          .collection('Cart')
          .where('coffeeId', isEqualTo: coffeeId)
          .get();

      // Her belgeyi sil
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }
  double calculateOrderPrice(List<Map<String, dynamic>> cartItems) {
    double totalPrice = 0.0;
    for (var cartItem in cartItems) {
      double coffeePrice = double.tryParse(cartItem['price'].toString()) ?? 0.0;
      int quantity = int.tryParse(cartItem['quantity'].toString()) ?? 1;
      totalPrice += coffeePrice * quantity;
    }
    //notifyListeners();
    return totalPrice;

  }
  Stream<List<Map<String, dynamic>>> getCartStream(String userId) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Cart')
        .snapshots() // Gerçek zamanlı güncellemeler için
        .asyncMap((cartSnapshot) async {
      List<Map<String, dynamic>> cartDetails = [];
      if (cartSnapshot.docs.isEmpty) {
        return cartDetails; // Sepet boşsa direkt boş liste döndür
      }

      List<String> coffeeIds = cartSnapshot.docs
          .map((cartItem) => cartItem.data()['coffeeId'] as String)
          .toList();

      final coffeesSnapshot = await FirebaseFirestore.instance
          .collection('Coffees')
          .where(FieldPath.documentId, whereIn: coffeeIds)
          .get();

      Map<String, dynamic> coffeeDataMap = {
        for (var doc in coffeesSnapshot.docs) doc.id: doc.data(),
      };

      for (var cartItem in cartSnapshot.docs) {
        final coffeeId = cartItem.data()['coffeeId'];
        final quantity = cartItem.data()['quantity'];
        final coffeeData = coffeeDataMap[coffeeId];

        if (coffeeData != null) {
          cartDetails.add({
            'coffeeId': coffeeId,
            'coffeeName': coffeeData['coffeeName'] ?? 'No Name',
            'shoutOrMilk': coffeeData['shoutOrMilk'] ?? 'No',
            'price': coffeeData['price'] ?? 0.0,
            'imageUrl': coffeeData['imageName'] ?? '',
            'quantity': quantity,
          });
        }
      }

      return cartDetails;
    });
  }
}