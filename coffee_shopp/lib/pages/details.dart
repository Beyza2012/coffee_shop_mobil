

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/cartItems.dart';
import '../classes/coffees.dart';
import '../service/cartProvider.dart';


class Details extends StatefulWidget {

  final Coffees coffee;

  const Details({Key? key, required this.coffee}) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
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
  int selectedSizeIndex=0;
  var sizeofcoffee = ["S","M","L"];

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20,left: 25),
                    child: Container(
                      width: 360,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          image: AssetImage("pictures/${widget.coffee.imageName}"), fit:BoxFit.fill,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0,left: 20),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${widget.coffee.coffeeName}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                            Text("${widget.coffee.shoutOrMilk}",style: TextStyle(color: Colors.grey,fontSize: 15),),

                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 17),
                        child: Container(
                          child: Row(
                            children: [
                              Icon(Icons.star,color: Color.fromRGBO(251, 190, 33, 1),size: 25,),
                              Text("${widget.coffee.point}",style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Container(
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Image.asset("pictures/iconcoffee1.png")
                              ),
                              SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Image.asset("pictures/iconcoffee2.png")
                              ),
                            ],
                          ),
                        ),
                      )

                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 20,bottom: 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Boyut",style: TextStyle(fontSize: 16)),
                        SizedBox(
                          width: 360,
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: sizeofcoffee.length,
                            itemBuilder: (context,indeks){
                              return GestureDetector(
                                onTap: (){
                                  setState(() {
                                    selectedSizeIndex = indeks;
                                  });
                                },
                                child: SizedBox(
                                  width: 120,
                                  child: Card(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: selectedSizeIndex ==indeks

                                            ? Color.fromRGBO(198, 124, 78, 1)
                                            : Color.fromRGBO(222, 222, 222, 1)
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        color: selectedSizeIndex == indeks
                                            ?  Color.fromRGBO(255, 245, 238, 1)
                                            : Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(sizeofcoffee[indeks],style: TextStyle(
                                            color: selectedSizeIndex == indeks
                                                ? Color.fromRGBO(198, 124, 78, 1)
                                                : Colors.black,
                                          ),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },),
                        )
                      ],
                    )

                  ],
                ),
              ),
            ],
          ),

        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromRGBO(255, 245, 238, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Fiyat",style: TextStyle(color: Colors.grey),),
                  Text(r"$" "${widget.coffee.price}",style: TextStyle(color: Color.fromRGBO(198, 124, 78, 1),fontSize: 20),)

                ],
              ),
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                 addToCart(userId, "${widget.coffee.coffeeId}", 1, context);
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => basket()));
                },
                style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(Color.fromRGBO(198, 124, 78, 1))
                ),
                child: Text("Sepete Ekle",style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),


    );
  }
}