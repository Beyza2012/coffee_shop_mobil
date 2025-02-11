import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shopp/pages/details.dart';
import 'package:coffee_shopp/service/cartProvider.dart';
import 'package:coffee_shopp/widgets/%20availableText.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/cartItems.dart';
import 'availableTitle.dart';
import '../classes/coffees.dart';

Future<void> addToCart(String userId, String coffeeId, int quantity, BuildContext context) async {
  try {
    // Firestore'daki 'Cart' koleksiyonuna referans alıyoruz
    final cartRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Cart');

    // Aynı coffeeId'ye sahip bir öğe zaten varsa, miktarı artırıyoruz
    final existingCartItem = await cartRef.where('coffeeId', isEqualTo: coffeeId).get();

    if (existingCartItem.docs.isNotEmpty) {
      // Eğer zaten varsa, mevcut öğeyi güncelliyoruz
      final docRef = existingCartItem.docs.first.reference;
      final newQuantity = existingCartItem.docs.first['quantity'] + quantity;

      await docRef.update({'quantity': newQuantity});
      print('Mevcut ürün miktarı artırıldı.');
    } else {
      // Eğer sepet boşsa, yeni öğe ekliyoruz
      final coffeeDetails = await FirebaseFirestore.instance
          .collection('Coffees')
          .doc(coffeeId)
          .get();

      final coffeeData = coffeeDetails.data();
      final price = coffeeData?['price'] ?? 0;

      await cartRef.add({
        'coffeeId': coffeeId,
        'quantity': quantity,
        'price': price,
        'totalPrice': price * quantity,
      });

      print('Yeni ürün sepete eklendi.');
    }

    // Sepet öğelerini güncelliyoruz
    final updatedCartSnapshot = await cartRef.get();
    final updatedCartItems = updatedCartSnapshot.docs.map((doc) {
      return CartItems.fromFirestore(doc.data());
    }).toList();

    // Provider'a güncel veriyi gönderiyoruz
    Provider.of<CartProvider>(context, listen: false).setCartItems(updatedCartItems);
  } catch (e) {
    print('Sepete ürün eklenemedi: $e');
  }
}


class CoffeeCard extends StatelessWidget {
  final Coffees coffee;

  const CoffeeCard({Key? key, required this.coffee}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => Details(coffee: coffee)));
      },
      child: Card(
        color: Colors.white,
        elevation: 8.0,
        margin: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 209,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage("pictures/${coffee.imageName}"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.star, color: Color.fromRGBO(251, 190, 33, 1), size: 15),
                    SizedBox(width: 4),
                    Text("${coffee.point}", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  AvailableTitle("${coffee.coffeeName}"),
                  AvailableText("${coffee.shoutOrMilk}")
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(right: 15,left: 15),
              child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   r"₺" "${coffee.price}",
                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color.fromRGBO(198, 124, 78, 1),),
                 ),
                 Container(
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(8),
                     color: Color.fromRGBO(198, 124, 78, 1),
                   ),
                   child: Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: GestureDetector(
                       onTap: () async{
                         await addToCart(userId, "${coffee.coffeeId}", 1, context); // Sepete ekle
                       },
                         child: Icon(Icons.add, color: Colors.white, size: 13)),
                   ),
                 ),
               ],
                            ),
            ),

          ],
        ),
      ),
    );
  }
}
