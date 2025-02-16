import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shopp/pages/addressPage.dart';
import 'package:coffee_shopp/service/adressesProvider.dart';
import 'package:coffee_shopp/service/creditCardsProvider.dart';
import 'package:coffee_shopp/widgets/%20availableText.dart';
import 'package:coffee_shopp/widgets/payment_address_list.dart';
import 'package:coffee_shopp/widgets/payment_card_form.dart';
import 'package:coffee_shopp/widgets/payment_selected_adress.dart';
import 'package:coffee_shopp/widgets/payment_selected_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../classes/Adresses.dart';
import '../classes/creditCards.dart';
import '../service/cartProvider.dart';
import '../widgets/availableTitle.dart';
import '../widgets/custom_dropdownbuttonfield.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/payment_card_list.dart';
import 'navigationBar.dart';
class paymentPage extends StatefulWidget {

  final List<Map<String, dynamic>> items;

  paymentPage({required this.items});

  @override
  State<paymentPage> createState() => _paymentPageState();
}

class _paymentPageState extends State<paymentPage> {

  Stream<List<Adresses>> getAdresses() {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('Adresses')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Adresses.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }



  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNameController = TextEditingController();
  final TextEditingController cardNoController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController holderNameController = TextEditingController();

  final List<String> months = List.generate(12, (index) => (index + 1).toString());
  final List<String> years = List.generate(10, (index) => (DateTime.now().year + index).toString());

  final currentUser = FirebaseAuth.instance.currentUser;
  bool saveCard = false;


  Stream<List<CreditCards>> getCreditCards(String userId) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('CreditCard')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CreditCards.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }
  Future<void> addCreditCard(CreditCards creditCard) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Daha önce kaydedilmiş kredi kartı olup olmadığını kontrol ediyoruz
        bool isFirstCard = (await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser?.uid)
            .collection('CreditCard')
            .get())
            .docs
            .isEmpty;

        // Yeni kredi kartını eklerken, eğer ilk kartsa selected: true, değilse selected: false
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser?.uid)
            .collection('CreditCard')
            .add({
          ...creditCard.toFirestore(),
          'selected': isFirstCard,  // İlk kartsa selected: true
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kredi kartı başarıyla eklendi!")),
        );
      } catch (e) {
        print("Hata oluştu: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ekleme sırasında bir hata oluştu.")),
        );
      }
    }
  }
  Future<String?> addCartItemsToFirestore(List<Map<String, dynamic>> cartItems, String userId,CreditCards selectedCard,Adresses selectedAdress) async {
    try {
      List<Map<String, dynamic>> itemsToSave = [];

      CollectionReference orderHistory = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('OrderHistory');

      itemsToSave = cartItems.where((item) {
        return !item.containsKey('finalTotalPrice');
      }).toList();

      // finalTotalPrice'i toplam tutar olarak hesapla
      double finalTotalPrice = 0;
      for (var itemsToSave in cartItems) {
        finalTotalPrice += (itemsToSave['price'] ?? 0) * (itemsToSave['quantity'] ?? 0);  // Fiyat * Miktar
      }

      // Sepetteki öğeleri alırken 'finalTotalPrice' hariç tutuyoruz

      var now = DateTime.now();
      var localDate = DateFormat('dd-MM-yyyy HH:mm:ss').format(now);
      // Firestore'a eklenecek veri
      Map<String, dynamic> orderData = {
        'orderItems': itemsToSave,  // CartItems listesindeki her öğeyi olduğu gibi kaydediyoruz
        'finalTotalPrice': finalTotalPrice,
        'orderDate':localDate, // Sipariş tarihi
        'paymentCard': {
          'cardNo': selectedCard.cardNo,
          'cardName': selectedCard.cardName,
          'holderName': selectedCard.holderName,
        },
        'paymentAdress':{
          'title': selectedAdress.title,
          'city': selectedAdress.city,
          'postalCode': selectedAdress.postalCode,
          'addressLine': selectedAdress.addressLine,
        }
      };

      // Firestore'a tek bir belge olarak kaydet
      await orderHistory.add(orderData);

      return 'Sipariş başarıyla verildi!';
    } catch (e) {
      return 'Sipariş işlemi sırasında hata oluştu: $e';
    }
  }

  late Stream<List<CreditCards>> creditCardStream;

  @override
  void initState() {
    super.initState();
    creditCardStream = getCreditCards(currentUser!.uid);
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Ödeme", style: TextStyle(fontSize: 25, color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<CreditCards>>(
              stream: creditCardStream,
              builder: (context, cardSnapshot) {
                if (cardSnapshot.connectionState == ConnectionState.waiting) {
                  // Eğer Stream henüz bağlanmadıysa CircularProgressIndicator göster
                  return Center(child: CircularProgressIndicator());
                }
                if (cardSnapshot.hasError) {
                  // Hata durumunda bir mesaj göster
                  return Center(
                      child: Text('Bir hata oluştu: ${cardSnapshot.error}'));
                }
                final creditCards = cardSnapshot.data ?? [];
                if (creditCards.isEmpty) {
                  return Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            color: Colors.white,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: screenHeight * 0.02,
                                    right: screenWidth * 0.10,
                                    left: screenWidth * 0.10,
                                    bottom: screenWidth * 0.02,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      AvailableTitle("Kart Bilgileri"),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Color.fromRGBO(198, 124, 78, 1), // Çizgi rengi
                                  thickness: 2,       // Kalınlık
                                  indent: 20,         // Soldan boşluk
                                  endIndent: 20,      // Sağdan boşluk
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: screenHeight * 0.02,
                                    right: screenWidth * 0.10,
                                    left: screenWidth * 0.10,
                                    bottom: screenWidth * 0.05,
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomTextFormField(
                                          controller: cardNameController,
                                          hintText: "Kart Adı",
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return "Bir kart adı girin.";
                                            } else {
                                              return null;}
                                          },
                                        ),
                                        SizedBox(height: 16),
                                        CustomTextFormField(
                                          controller: cardNoController,
                                          hintText: "Kart Numarası",
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return "Bir kart numarası girin.";
                                            } else {return null;}
                                          },
                                        ),
                                        SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(right:screenWidth * 0.03 ),
                                                child: CustomDropdownFormField(
                                                  controller: monthController,
                                                  hintText:"Ay",
                                                  items: months,
                                                  onChanged: (selectedMonth) {
                                                    // Seçilen ay controller'a aktarılır
                                                  },
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return "Ay seçimi zorunludur.";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(left: screenWidth * 0.03 ),
                                                child: CustomDropdownFormField(
                                                  controller: yearController,
                                                  hintText: "Yıl",
                                                  items: years,
                                                  onChanged: (selectedYear) {
                                                    // Seçilen yıl controller'a aktarılır
                                                  },
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return "Yıl seçimi zorunludur.";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        CustomTextFormField(
                                          controller: cvvController,
                                          hintText: "CVV",
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return "CVV girin.";
                                            } else {return null;}
                                          },
                                        ),
                                        SizedBox(height: 16),
                                        CustomTextFormField(
                                          controller: holderNameController,
                                          hintText: "Kart Üzrindeki İsim",
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return "Bir isim girin.";
                                            } else {
                                              return null;}
                                          },
                                        ),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: saveCard,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  saveCard = value ?? false;
                                                });
                                              },
                                            ),
                                            Text("Kartı Kaydet"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                      ),


                    ],
                  ); // Eğer kart yoksa form göster
                }
                else{
                  CreditCards? selectedCard = creditCards.isNotEmpty
                      ? creditCards.firstWhere(
                        (card) => card.selected ?? false,
                    orElse: () => creditCards.first,
                  )
                      : null; // Eğer liste boşsa, null ata

                  Provider.of<CreditCardProvider>(context, listen: false).setSelectedCard(selectedCard!);

                  // **Eğer kredi kartları varsa, listeyi göster**
                  return Card(
                    child:
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: screenHeight * 0.02,
                            right: screenWidth * 0.10,
                            left: screenWidth * 0.10,
                            bottom: screenWidth * 0.02,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AvailableTitle("Kart Bilgileri"),
                            ],
                          ),
                        ),
                        Divider(
                          color: Color.fromRGBO(198, 124, 78, 1), // Çizgi rengi
                          thickness: 2,       // Kalınlık
                          indent: 20,         // Soldan boşluk
                          endIndent: 20,      // Sağdan boşluk
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: screenHeight * 0.02,
                            right: screenWidth * 0.06,
                            left: screenWidth * 0.06,
                            bottom: screenWidth * 0.05,
                          ),
                          child: Column(
                            children: [
                              // Seçili olan kartı göster
                              PaymentSelectedCard(card: selectedCard),

                              // Kart değiştirme butonu
                              TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return PaymentCardList( creditCards: creditCards);
                                    },
                                  );
                                },
                                child: AvailableText("Kart Değiştir"),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

              },
            ),
            Column(
              children: [
                StreamBuilder<List<Adresses>>(
                  stream: getAdresses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Bir hata oluştu."));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Column(children:[
                        AvailableText("Henüz bir adres girilmedi."),
                        GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Adresspage()));
                            },
                            child: AvailableText("Bir adres giriniz.")),


                      ] );
                    }
                    final adresses = snapshot.data ?? [];
                    // **Seçili olan adresi bul**
                    Adresses? selectedAdress = adresses.firstWhere(
                          (adress) => adress.selected ?? false,
                      orElse: () => adresses.first, // Eğer seçili adres yoksa ilk adresi göster
                    );
                    Provider.of<AdressesProvider>(context, listen: false).setSelectedAdress(selectedAdress);

                    return Card(
                      child:
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: screenHeight * 0.02,
                              right: screenWidth * 0.10,
                              left: screenWidth * 0.10,
                              bottom: screenWidth * 0.02,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AvailableTitle("Seçili Adres"),
                              ],
                            ),
                          ),
                          Divider(
                            color: Color.fromRGBO(198, 124, 78, 1), // Çizgi rengi
                            thickness: 2,       // Kalınlık
                            indent: 20,         // Soldan boşluk
                            endIndent: 20,      // Sağdan boşluk
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: screenHeight * 0.02,
                              right: screenWidth * 0.06,
                              left: screenWidth * 0.06,
                              bottom: screenWidth * 0.05,
                            ),
                            child: Column(
                              children: [
                                // Seçili olan kartı göster
                                PaymentSelectedAdress(adress: selectedAdress),

                                // Kart değiştirme butonu
                                TextButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return PaymentAddressList(adresses: adresses);
                                      },
                                    );
                                  },
                                  child: AvailableText("Adres Değiştir"),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    );

                  },
                ),
              ],
            ),

          ],
        ),
      ),
      bottomNavigationBar: buildBottomBar(),
    );

  }

  Widget buildBottomBar() {
    return BottomAppBar(
      color: Color.fromRGBO(255, 245, 238, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Toplam", style: TextStyle(color: Colors.grey)),
                Text("\₺${widget.items.last.values.first.toString()}", style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              style:  ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all<Color>(Color.fromRGBO(198, 124, 78, 1))
              ),
              onPressed: () async {
                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                final creditCardProvider = Provider.of<CreditCardProvider>(context, listen: false);
                final adressProvider = Provider.of<AdressesProvider>(context, listen: false);

                final selectedCard = creditCardProvider.selectedCard;
                final selectedAdress = adressProvider.selectedAdress;
                if (selectedCard != null && selectedAdress != null) {
                  String? result = await addCartItemsToFirestore(widget.items, currentUser!.uid, selectedCard, selectedAdress);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result ?? "Bilinmeyen hata.")),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => BarMenu()),
                        (route) => false,
                  );
                  cartProvider.clearCart(currentUser!.uid);
                }
                else if(selectedCard == null && selectedAdress != null && _formKey.currentState!.validate()) {
                  final newCard = CreditCards(
                      cardNo: cardNoController.text,
                      month: monthController.text,
                      years: yearController.text,
                      cvv: cvvController.text,
                      cardName: cardNameController.text,
                      holderName: holderNameController.text);
                  if (saveCard) {
                    addCreditCard(newCard);
                  }
                  String? result = await addCartItemsToFirestore(widget.items, currentUser!.uid, newCard, selectedAdress);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result ?? "Bilinmeyen hata.")),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => BarMenu()),
                        (route) => false,
                  );
                  cartProvider.clearCart(currentUser!.uid);
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("sipariş alınamadı")),
                  );
                }

              },

              child: Text("Ödeme Yap",style: TextStyle(color: Colors.white),),

            ),


          ),
        ],
      ),
    );
  }
}


