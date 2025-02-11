import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shopp/classes/creditCards.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/ availableText.dart';
import '../widgets/availableTitle.dart';
import '../widgets/custom_dropdownbuttonfield.dart';
import '../widgets/custom_text_form_field.dart';

class Creditcardpage extends StatefulWidget {
  const Creditcardpage({super.key});

  @override
  State<Creditcardpage> createState() => _CreditcardpageState();
}

class _CreditcardpageState extends State<Creditcardpage> {
  final _formKey = GlobalKey<FormState>();

  List<CreditCards> allCreditCartsList = [];
  String? selectedMonth;
  String? selectedYear;

  final  monthController = TextEditingController();
  final  yearController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getcreditCards();
    // Başlangıç ay ve yılını ayarla
    selectedMonth = "01"; // İlk ay olarak Ocak
    selectedYear = "2025"; // Başlangıç yılı olarak 2025
    monthController.text = selectedMonth!;
    yearController.text = selectedYear!;
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  bool addOrUpdate = true;
  Future<void> getcreditCards() async {
    List<CreditCards> creditCartsList = [];
    try{
      if (currentUser == null) {
        throw Exception("Oturum açmış kullanıcı bulunamadı.");
      }

      final QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('Users').doc(currentUser?.uid).collection('CreditCard').get();
      if(snapshot.docs.isNotEmpty){
        for(var doc in snapshot.docs){
          print("Veri Çekildi: ${doc.data()}");
          creditCartsList.add(CreditCards.fromFirestore(doc.id, doc.data() as Map<String, dynamic>));
        }
        setState(() {
          allCreditCartsList = creditCartsList;  // Listeyi güncelle
        });
      }
    }
    catch(e){
      print(e);
    }

  }
  Future<void> deleteCreditCard(CreditCards creditCard) async {
    try{
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser?.uid)
          .collection('CreditCard')
          .doc(creditCard.id)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kredi kartı silindi!")),
      );

    }catch(e){
      print("Hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Silme sırasında bir hata oluştu.")),
      );

    }

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

        // Kredi kartını listeye ekliyoruz, selected değerini true veya false olarak ayarlıyoruz
        setState(() {
          allCreditCartsList.add(
            CreditCards(
              id: docRef.id,
              cardNo: creditCard.cardNo,
              month: creditCard.month,
              years: creditCard.years,
              cvv: creditCard.cvv,
              cardName: creditCard.cardName,
              holderName: creditCard.holderName,
              selected: isFirstCard,  // İlk kartsa selected: true
            ),
          );
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

  Future<void> updateCreditCard(CreditCards creditCard) async {
    if (_formKey.currentState!.validate()){
      try{
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser?.uid)
            .collection('CreditCard')
            .doc(creditCard.id)
            .update(creditCard.toFirestore());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kredi kartı bilgileri güncellendi!")),
        );

      }catch(e){
        print("Hata oluştu: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Güncelleme sırasında bir hata oluştu.")),
        );
      }
    }

  }
  void showAlertDialog(BuildContext context, CreditCards creditCard){
    showDialog(context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: AvailableTitle("Silme işlemi:"),
            content: AvailableText("Kredi kartını silmek istediğinizden emin misiniz?"),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    deleteCreditCard(creditCard);
                    allCreditCartsList.remove(creditCard);
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(198, 124, 78, 1),
                  foregroundColor: Colors.white,
                ),
                child: Text("Sil"),
              ),
            ],
          );
        });
  }
  void showEditBottomSheet(BuildContext context, CreditCards? creditCard) {
    List<String> months = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
    List<String> years = List.generate(20, (index) => (2025 + index).toString());

    final screenWidth = MediaQuery.of(context).size.width;
    final cardNoController = TextEditingController(text: creditCard?.cardNo ?? null);
    final  cardNameController = TextEditingController(text: creditCard?.cardName ?? null);
    final  cvvController = TextEditingController(text: creditCard?.cvv ?? null);
    final  holderNameController = TextEditingController(text: creditCard?.holderName ?? null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFormField(
                    controller: cardNameController,
                    hintText: "Kart Name",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Bir posta kodu girin.";
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
                            hintText: "Ay Seçiniz",
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
                            hintText: "Yıl Seçiniz",
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
                    hintText: "Kart Üzerindeki İsim",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Bir isim girin.";
                      } else {
                        return null;}
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(198, 124, 78, 1),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // Yeni adres ya da güncellenmiş adresi oluşturuyoruz.
                      final newCreditCard = CreditCards(
                          id: creditCard?.id ?? null,
                          cardNo: cardNoController.text,
                          month: monthController.text,
                          years: yearController.text,
                          cvv: cvvController.text,
                          cardName: cardNameController.text,
                          holderName: holderNameController.text);
                      if (creditCard == null) {
                        addCreditCard(newCreditCard);
                        Navigator.pop(context); // Adres eklendikten sonra BottomSheet'i kapat
                      }
                      else {
                        // Var olan adres güncelleniyor.
                        updateCreditCard(newCreditCard).then((_) {
                          setState(() {
                            // Listeyi güncelliyoruz
                            int index = allCreditCartsList.indexWhere((item) => item.id == newCreditCard.id);
                            if (index != -1) {
                              allCreditCartsList[index] = newCreditCard;
                            }
                          });
                          Navigator.pop(context); // Bottom Sheet'i kapatıyoruz.
                        });
                      }
                    },
                    child: Text(creditCard == null ? "Kart Ekle" : "Kart Güncelle"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Kredi Kartlarım", style: TextStyle(fontSize: 25, color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Column(
            children: [
              SizedBox(
                height: screenHeight * 0.5,
                child: ListView.builder(
                  itemCount: allCreditCartsList.length,
                  itemBuilder: (context,index){
                    final card = allCreditCartsList[index];
                    return Column(
                      children: [
                        Card(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ListTile(
                              leading: Icon(
                                Icons.location_on,
                                color: Color.fromRGBO(198, 124, 78, 1),
                              ),
                              title: Text(card.cardName), // Adres başlığını göstermek için
                              subtitle: Text(
                                '${card.cardNo}, ${card.month}, ${card.years}',
                              ),
                              trailing: PopupMenuButton<int>(
                                  onSelected:(value){
                                    setState(() {
                                      if(value == 1 ){
                                        showAlertDialog(context, card);

                                      }
                                      else if (value == 2) {
                                        addOrUpdate = true;
                                        showEditBottomSheet(context, card);
                                      }
                                    });

                                  },
                                  itemBuilder:(BuildContext context)=>[
                                    const PopupMenuItem(
                                      value: 1,
                                      child: Text('sil'),
                                    ),
                                    const PopupMenuItem(
                                      value: 2,
                                      child: Text('güncelle'),
                                    ),
                                  ]
                              )
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        color: Color.fromRGBO(255, 245, 238, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  _formKey.currentState?.reset();
                  addOrUpdate = false;
                  showEditBottomSheet(context, null);

                },
                style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(Color.fromRGBO(198, 124, 78, 1))
                ),
                child: Text("Kart Ekle ",style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
