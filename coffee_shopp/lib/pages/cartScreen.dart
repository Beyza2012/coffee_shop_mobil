import 'package:coffee_shopp/classes/cartItems.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../classes/coffees.dart';
import 'login_register_page.dart';
import 'paymentPage1.dart';
import '../widgets/ availableText.dart';
import '../widgets/availableTitle.dart';
import '../service/cartProvider.dart';

class CartScreen extends StatelessWidget {
  final String userId;

  CartScreen({required this.userId});
  final currentUser = FirebaseAuth.instance.currentUser;



  Stream<List<Map<String, dynamic>>> getCartWithTotalPrice(String userId) {
    return Rx.combineLatest2(
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Cart')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return CartItems.fromFirestore(doc.data());
        }).toList();
      }),
      FirebaseFirestore.instance.collection('Coffees').snapshots().map((snapshot) {
        Map<String, Coffees> coffeeMap = {};
        for (var doc in snapshot.docs) {
          final coffee = Coffees.fromFirestore(doc.id, doc.data());
          coffeeMap[doc.id] = coffee;
        }
        return coffeeMap;
      }),
          (List<CartItems> cartItems, Map<String, Coffees> coffeeItems) {
        double finalTotalPrice = 0;

        var updatedCartItems = cartItems.map((cartItem) {
          final coffeeDetails = coffeeItems[cartItem.coffeeId];
          final coffeeName = coffeeDetails?.coffeeName ?? 'Unknown Coffee';
          final shoutOrMilk = coffeeDetails?.shoutOrMilk ?? 'No Milk';
          final imageName = coffeeDetails?.imageName ?? 'No image';
          final price = coffeeDetails?.price ?? 0;
          final totalPrice = price * cartItem.quantity;

          // Sepetteki her bir öğenin finalTotalPrice'ını güncelle
          cartItem.finalTotalPrice = totalPrice.toDouble();

          finalTotalPrice += cartItem.finalTotalPrice!;

          return {
            'coffeeId': cartItem.coffeeId,
            'coffeeName': coffeeName,
            'shoutOrMilk': shoutOrMilk,
            'quantity': cartItem.quantity,
            'imageName': imageName,
            'price': price,
            'totalPrice': totalPrice,
          };
        }).toList();

        updatedCartItems.add({
          'finalTotalPrice': finalTotalPrice, // Toplam fiyatı güncellenmiş olarak ekle
        });

        return updatedCartItems;
      },
    );
  }





  Future<void> removeProductFromCart(String userId, String coffeeId, BuildContext context) async {
    try {
      final cartRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Cart');

      final cartDoc = await cartRef.where('coffeeId', isEqualTo: coffeeId).get();

      if (cartDoc.docs.isNotEmpty) {
        await cartDoc.docs.first.reference.delete();

        // Provider'dan removeItem çağırarak sepeti güncelle
        Provider.of<CartProvider>(context, listen: false).removeFromCart(coffeeId);

        print('Ürün sepetten başarıyla çıkarıldı.');
      }
    } catch (e) {
      print('Sepetten ürün çıkarılamadı: $e');
    }
  }



  void showAlertDialog(BuildContext context){
    showDialog(context: context,
        builder: (BuildContext context){
          return AlertDialog(
            content: AvailableText("Sipariş için kullanıcı girişi yapılmalı!"),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_)=> LoginRegisterPage()),
                          (Route<dynamic> route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(198, 124, 78, 1),
                  foregroundColor: Colors.white,
                ),
                child: Text("Kayıt Ol"),
              ),
            ],
          );
        });
  }
  double totalPrice = 0;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sepetim'),
        automaticallyImplyLeading: false, // Geri butonunu kaldırır
        centerTitle: true, // Başlık metnini ortalar
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream:  getCartWithTotalPrice(userId),
        builder: (context, cartSnapshot) {
          if (cartSnapshot.connectionState == ConnectionState.waiting) {
            // Eğer Stream henüz bağlanmadıysa CircularProgressIndicator göster
            return Center(child: CircularProgressIndicator());
          }
          if (cartSnapshot.hasError) {
            // Hata durumunda bir mesaj göster
            return Center(child: Text('Bir hata oluştu: ${cartSnapshot.error}'));

          }
          if (!cartSnapshot.hasData || cartSnapshot.data == null || cartSnapshot.data!.isEmpty) {
            // Boş veri durumunda bir mesaj göster
            return Center(child: Text('Sepetiniz boş.'));
          }

          // Veriler düzgün geldiyse UI'yi oluştur
          final cartItems = cartSnapshot.data!;
          // Eğer sadece finalTotalPrice varsa, sepetin gerçekten boş olduğunu anlarız.
          if (cartItems.length == 1 && cartItems.first.containsKey('finalTotalPrice')) {
            return Center(
              child: Text(
                'Sepetiniz boş.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            );
          }

          totalPrice = cartItems.last['finalTotalPrice'] ?? 0.0;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length- 1,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return SizedBox(
                      height: screenHeight * 0.2,
                      child: Card(
                        color: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image Section
                            Container(
                              width: screenWidth * 0.28,
                              height: screenHeight * 0.12,
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: AssetImage("pictures/${item['imageName']}"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Details Section
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.02,
                                  horizontal: screenWidth * 0.02,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AvailableTitle(
                                            item['coffeeName'],
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.03,
                                        ),
                                        AvailableText(
                                          item['shoutOrMilk'],
                                        ),
                                      ],
                                    ),
                                    Text(
                                      r"₺" "${item['totalPrice']}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(198, 124, 78, 1),
                                      ),
                                    ),
                                    Container(
                                      width: 100,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Color.fromRGBO(198, 124, 78, 1), // Border rengi
                                          width: 1, // Border kalınlığı
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              // Azaltma işlemi
                                              Provider.of<CartProvider>(context, listen: false)
                                                  .decreaseQuantity(item['coffeeId']);
                                            },
                                            child: AvailableTitle(
                                              '-',
                                            ),
                                          ),
                                          AvailableText(
                                            "${item['quantity']}",
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              // Arttırma işlemi
                                              Provider.of<CartProvider>(context, listen: false)
                                                  .increaseQuantity(item['coffeeId']);
                                            },
                                            child: AvailableTitle(
                                              '+',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: ()  {
                                removeProductFromCart(userId, item['coffeeId'], context);
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Color.fromRGBO(198, 124, 78, 1),
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                  },
                ),
              ),
              if (cartItems.length > 1)
              BottomAppBar(
                color: Color.fromRGBO(255, 245, 238, 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Toplam",style: TextStyle(color: Colors.grey),),
                          Text(
                            "\₺${totalPrice.toStringAsFixed(2)}",
                            style: TextStyle(fontSize: 20),
                          ),


                        ],
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          if(currentUser!.isAnonymous){
                            showAlertDialog(context);
                          }else{
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => paymentPage(items: cartItems),
                                )
                            );
                          }

                        },
                        style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              ),
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(Color.fromRGBO(198, 124, 78, 1))
                        ),
                        child: Text("Sepeti Onayla",style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ],
                ),
              ),


            ],
          );
        },
      ),
    );
  }
}