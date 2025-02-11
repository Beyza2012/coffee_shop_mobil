import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shopp/classes/Adresses.dart';
import 'package:coffee_shopp/widgets/availableTitle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/ availableText.dart';
import '../widgets/custom_text_form_field.dart';

class Adresspage extends StatefulWidget {
  const Adresspage({super.key});

  @override
  State<Adresspage> createState() => _AdresspageState();
}

class _AdresspageState extends State<Adresspage> {
  final _formKey = GlobalKey<FormState>();
  List<Adresses> allAdressList = [];

  final currentUser = FirebaseAuth.instance.currentUser;
  bool addOrUpdate = true;
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    getAdresses().then((alladressList){
      setState(() {
        allAdressList = alladressList;
      });
    });
  }

  Future<List<Adresses>> getAdresses() async {
    List<Adresses> adressList = [];
    try{
      if (currentUser == null) {
        throw Exception("Oturum açmış kullanıcı bulunamadı.");
      }

          final QuerySnapshot snapshot =
              await FirebaseFirestore.instance.collection('Users').doc(currentUser?.uid).collection('Adresses').get();
          if(snapshot.docs.isNotEmpty){
            for(var doc in snapshot.docs){
              print("Veri Çekildi: ${doc.data()}");
              adressList.add(Adresses.fromFirestore(
                  doc.id, // Firestore'dan gelen belge ID'si
                  doc.data() as Map<String, dynamic>)
              );
            }
          }
    }
    catch(e){
      print(e);
    }
    return adressList;
  }
  Future<void> deleteAddress(Adresses address) async {
    try{
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser?.uid)
          .collection('Adresses')
          .doc(address.id)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Adres başarıyla silindi!")),
      );

    }catch(e){
      print("Hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Silme sırasında bir hata oluştu.")),
      );

    }

  }

  Future<void> addAddress(Adresses address) async {
    if (_formKey.currentState!.validate()) {
      try {
        CollectionReference addressesRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser?.uid)
            .collection('Adresses');

        // Kullanıcının adres koleksiyonundaki adres sayısını kontrol et
        QuerySnapshot existingAddresses = await addressesRef.get();
        bool isFirstAddress = existingAddresses.docs.isEmpty; // Eğer koleksiyon boşsa, bu ilk adres

        // Yeni adresi ekleyip Firestore'un verdiği belge ID'sini alıyoruz
        DocumentReference docRef = await addressesRef.add({
          ...address.toFirestore(),
          "selected": isFirstAddress, // İlk adresse true, değilse false
        });

        // Yeni adresin ID'sini güncelleyerek listeye ekliyoruz
        setState(() {
          allAdressList.add(
            Adresses(
              id: docRef.id, // Firestore'un oluşturduğu ID
              title: address.title,
              addressLine: address.addressLine,
              city: address.city,
              postalCode: address.postalCode,
              selected: isFirstAddress, // İlk adres mi kontrolü
            ),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Adres başarıyla eklendi!")),
        );
        Navigator.pop(context); // Adres eklendikten sonra BottomSheet'i kapat
      } catch (e) {
        print("Hata oluştu: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ekleme sırasında bir hata oluştu.")),
        );
      }
    }
  }


  Future<void> updateAddress(Adresses address) async {
    if (_formKey.currentState!.validate()){
    try{
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser?.uid)
          .collection('Adresses')
          .doc(address.id)
          .update(address.toFirestore());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Adres başarıyla güncellendi!")),
      );
      Navigator.pop(context);

    }catch(e){
    print("Hata oluştu: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Güncelleme sırasında bir hata oluştu.")),
    );
    }
    }

  }

  void showAlertDialog(BuildContext context, Adresses address){
      showDialog(context: context,
          builder: (BuildContext context){
         return AlertDialog(
             title: AvailableTitle("Silme işlemi:"),
           content: AvailableText("Adresi silmek istediğinizden emin misiniz?"),
           actions: [
             ElevatedButton(
               onPressed: () async {
                   setState(() {
                     deleteAddress(address);
                     allAdressList.remove(address);
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
  void showEditBottomSheet(BuildContext context, Adresses? address) {
    final titleController = TextEditingController(text: address?.title ?? null);
    final addressLineController =
    TextEditingController(text: address?.addressLine ?? null);
    final cityController = TextEditingController(text: address?.city ?? null);
    final postalCodeController =
    TextEditingController(text: address?.postalCode ?? null);

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
                  SizedBox(height: 16),
                  CustomTextFormField(
                    controller: titleController,
                    hintText: "Adres Başlığı",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Bir adres başlığı girin.";
                      } else {return null;}
                    },
                  ),
                  SizedBox(height: 16),
                  CustomTextFormField(
                    controller: addressLineController,
                    hintText: "Adres Detayı",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Bir Adres Detayı girin.";
                      } else {return null;}
                    },
                  ),
                  SizedBox(height: 16),
                  CustomTextFormField(
                    controller: cityController,
                    hintText: "Şehir",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Bir şehir girin.";
                      } else {return null;}
                    },
                  ),
                  SizedBox(height: 16),
                  CustomTextFormField(
                    controller: postalCodeController,
                    hintText: "Posta Kodu",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Bir posta kodu girin.";
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
                      final newAddress = Adresses(
                        id: address?.id ?? null,  // Eğer yeni bir adresse id boş olabilir
                        title: titleController.text,
                        addressLine: addressLineController.text,
                        city: cityController.text,
                        postalCode: postalCodeController.text,
                      );
                      if (address == null) {
                        addAddress(newAddress);

                      }
                      else {
                        // Var olan adres güncelleniyor.
                        updateAddress(newAddress).then((_) {
                          setState(() {
                            // Listeyi güncelliyoruz
                            int index = allAdressList.indexWhere((item) => item.id == newAddress.id);
                            if (index != -1) {
                              allAdressList[index] = newAddress;
                            }
                          });
                        });
                      }
                    },
                    child: Text(address == null ? "Adres Ekle" : "Adres Güncelle"),
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
        title: Text("Adreslerim", style: TextStyle(fontSize: 25, color: Colors.black)),
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
                  itemCount: allAdressList.length,
                  itemBuilder: (context,index){
                    final adress = allAdressList[index];
                    return Column(
                      children: [
                        Card(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                        leading: Icon(
                        Icons.location_on,
                        color: Color.fromRGBO(198, 124, 78, 1),
                        ),
                        title: Text(adress.title), // Adres başlığını göstermek için
                        subtitle: Text(
                        '${adress.addressLine}, ${adress.city}, ${adress.postalCode}',
                        ),
                        trailing: PopupMenuButton<int>(
                        onSelected:(value){
                            setState(() {
                            if(value == 1 ){
                                showAlertDialog(context, adress);

                            }
                            else if (value == 2) {
                              addOrUpdate = true;
                              showEditBottomSheet(context, adress);
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
                child: Text("Adres Ekle ",style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
