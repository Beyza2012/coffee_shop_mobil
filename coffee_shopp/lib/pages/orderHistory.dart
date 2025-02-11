import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shopp/widgets/%20availableText.dart';
import 'package:coffee_shopp/widgets/availableTitle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../classes/coffees.dart';

class Orderhistory extends StatelessWidget {
  final String userId;
  Orderhistory({required this.userId});


  Future<List<Map<String, dynamic>>> getOrderDetails(String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference orderHistory =
    firestore.collection('Users').doc(userId).collection('OrderHistory');

    QuerySnapshot snapshot = await orderHistory.orderBy('orderDate', descending: true).get();

    List<Map<String, dynamic>> orders = [];

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      List<dynamic> orderItemsList = data['orderItems'];
      List<Coffees> detailedCoffeeList = [];

      for (var item in orderItemsList) {
        String coffeeId = item['coffeeId'];  // Firestore'da kahve ID'sini al

        // Kahve bilgilerini 'Coffees' koleksiyonundan çek
        DocumentSnapshot coffeeSnapshot =
        await firestore.collection('Coffees').doc(coffeeId).get();

        if (coffeeSnapshot.exists) {
          var coffeeData = coffeeSnapshot.data() as Map<String, dynamic>;

          // 'Coffees' sınıfından bir nesne oluştur
          Coffees coffee = Coffees.fromFirestore(coffeeSnapshot.id, coffeeData);

          detailedCoffeeList.add(coffee);
        }
      }

      // Sipariş verisini kahve detaylarıyla birlikte listeye ekle
      orders.add({
        'orderDate': data['orderDate'],
        'finalTotalPrice': data['finalTotalPrice'],
        'coffees': detailedCoffeeList,
      });
    }

    return orders;
  }
  // Date format fonksiyonu



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Ödeme Geçmişi", style: TextStyle(fontSize: 25, color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: 500,
            height: 780,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getOrderDetails(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No order history available.');
                } else {
                  var orders = snapshot.data!;
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      var order = orders[index];
                      List<Coffees> coffeeList = order['coffees'];

                      return Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  AvailableText(
                                    "${order['orderDate']}",
                                  ),
                                  AvailableText(
                                    "Toplam Fiyat: ${order['finalTotalPrice']}₺",
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Column(
                                children: coffeeList.map((coffee) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),

                                    ),
                                    child: ListTile(
                                      leading:
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                    width: 50,
                                    height: 100,
                                    decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                    image: AssetImage("pictures/${coffee.imageName}"),
                                    fit: BoxFit.fill,
                                    ),
                                    ),),
                                  ),
                                      title: AvailableTitle(
                                        coffee.coffeeName,
                                      ),
                                      trailing: AvailableTitle(
                                        "${coffee.price}₺",
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),

          ),

        ],
      ),
    );
  }
}
