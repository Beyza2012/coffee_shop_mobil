import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../classes/cartItems.dart';
import '../classes/creditCards.dart';

class CartProvider extends ChangeNotifier {
  List<CartItems> _cartItems = []; // Sepetteki öğeler
  double _finalTotalPrice = 0.0; // Sepet toplam fiyatı

  // Sepetteki öğeleri almak
  List<CartItems> get cartItems => _cartItems;
  double get finalTotalPrice => _finalTotalPrice;

  // Sepete ürün eklemek
  void addToCart(CartItems item) {
    _cartItems.add(item);
    _updateFinalTotalPrice();  // finalTotalPrice'ı güncelle
    notifyListeners();
  }

  // Sepetten ürün çıkartmak
  void removeFromCart(String coffeeId) {
    _cartItems.removeWhere((item) => item.coffeeId == coffeeId);
    _updateFinalTotalPrice();  // finalTotalPrice'ı güncelle
    notifyListeners();
  }

  // Sepet öğelerini güncellemek
  void setCartItems(List<CartItems> items) {
    _cartItems = items;
    _updateFinalTotalPrice();  // finalTotalPrice'ı güncelle
    notifyListeners();
  }

  // Toplam final fiyatı hesaplamak
  void _updateFinalTotalPrice() {
    _finalTotalPrice = _cartItems.fold(0.0, (sum, item) {
      return sum + item.totalPrice; // Her ürünün totalPrice'ını toplar
    });
  }
  void increaseQuantity(String coffeeId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Cart')
        .where('coffeeId', isEqualTo: coffeeId);

    final cartDoc = await cartRef.get();
    if (cartDoc.docs.isNotEmpty) {
      final doc = cartDoc.docs.first;
      int currentQuantity = doc['quantity'];
      doc.reference.update({'quantity': currentQuantity + 1});
      notifyListeners();
    }
  }

  void decreaseQuantity(String coffeeId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Cart')
        .where('coffeeId', isEqualTo: coffeeId);

    final cartDoc = await cartRef.get();
    if (cartDoc.docs.isNotEmpty) {
      final doc = cartDoc.docs.first;
      int currentQuantity = doc['quantity'];
      if (currentQuantity > 1) {
        doc.reference.update({'quantity': currentQuantity - 1});
      } else {
        doc.reference.delete(); // Eğer 1'e düşerse ürünü sepetten kaldır
      }
      notifyListeners();
    }
  }
  Future<void> clearCartFirestore(String userId) async {
    try {
      final cartRef = FirebaseFirestore.instance.collection('Users').doc(userId).collection('Cart');
      final cartDocs = await cartRef.get();

      // Firestore'daki her öğeyi sil
      for (var doc in cartDocs.docs) {
        await doc.reference.delete();
      }
      print('Sepet Firestore’dan başarıyla temizlendi.');
    } catch (e) {
      print('Sepet Firestore’dan temizlenemedi: $e');
    }
  }
  // Sepeti temizle
  Future<void> clearCart(String userId) async {
    // Local CartProvider'ı temizle
    _cartItems.clear();

    // Firestore'daki veriyi temizle
    await clearCartFirestore(userId);

    notifyListeners();
  }

}


