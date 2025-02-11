
import 'dart:io';

import 'package:coffee_shopp/pages/addressPage.dart';
import 'package:coffee_shopp/pages/accountSettings.dart';
import 'package:coffee_shopp/pages/creditCardPage.dart';
import 'package:coffee_shopp/pages/navigationBar.dart';
import 'package:coffee_shopp/pages/orderHistory.dart';
import 'package:coffee_shopp/widgets/%20availableText.dart';
import 'package:coffee_shopp/widgets/availableTitle.dart';
import 'package:coffee_shopp/classes/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../service/auth.dart';
import 'package:coffee_shopp/pages/login_register_page.dart';

class Userpage extends StatefulWidget {
  const Userpage({super.key});

  @override
  State<Userpage> createState() => _UserpageState();
}

class _UserpageState extends State<Userpage> {

  List<String> registerOrLogin = ["Register","Login"];
  String selected = "Login";

  final Auth _auth = Auth();


  Users? user;

  Future<void> getUser() async {
    try {
      final userDetails = await _auth.getUserDetails();

      setState(() {
        user = userDetails ??
            Users(email: 'No email', userName: 'No name',isAnonymous: true, photoURL: 'no photo');
            // Kullanıcı bilgisi yoksa varsayılan anonim kullanıcı
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bir hata oluştu: $e")),
      );
    }
  }
  void initState() {
    super.initState();
    getUser();  // Kullanıcı bilgisini al
  }
  File? _image; // Seçilen fotoğrafı tutacak değişken
  final ImagePicker _picker = ImagePicker(); // Seçilen fotoğrafı tutacak değişken
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Fotoğrafı Firebase Storage'a yükle
      if (_image != null) {
        String? photoURL = await _auth.uploadProfilePicture(_image!);

        if (photoURL != null) {
          setState(() {
            user!.photoURL = photoURL; // Yüklenen fotoğraf URL'sini kullanıcı bilgisine ekle
          });
          print("Fotoğraf URL'si: $photoURL");
        } else {
          print("Fotoğraf yüklenemedi.");
        }
      }
    }
  }
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body:
      user != null ?
      user!.isAnonymous ?
      //Kullanıcı anonimse:
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(80.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => LoginRegisterPage(),
                )
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(198, 124, 78, 1),
                foregroundColor: Colors.white,
              ),
              child: const Text("Hesabın varsa Giriş Yap"),
            ),
          ),


        ],
      )
      : //kullanıcı girişi varsa

      Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.03),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      user!.photoURL == null
                          ? GestureDetector(
                          onTap: (){
                            _pickImage();
                          },
                          child: Icon(Icons.account_circle, size: 100,color: Color.fromRGBO(198, 124, 78, 1),))
                          : ClipOval(
                          child: Image.asset("pictures/${user!.photoURL}") // Storage olsaydı image.network kullanıcaktık
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AvailableTitle("${user!.userName}"),
                      AvailableText("${user!.email}"),
                    ],
                  ),

                ],
              ),
            ),
            Container(
              height: 1, // Çizginin kalınlığı
              margin: EdgeInsets.symmetric(horizontal: 0), // Kenarlardan boşluk
              decoration: BoxDecoration(
                color: Colors.grey, // Çizginin ana rengi
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(67, 37, 0, 0.76), // Gölgenin rengi
                    spreadRadius: 1, // Gölgenin yayılma alanı
                    blurRadius: 5, // Gölgenin bulanıklık miktarı
                    offset: Offset(0, 3), // Gölgenin yatay ve dikey pozisyonu
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: screenHeight * 0.5,
                child: ListView(
                  children: [
                    GestureDetector(
                      child: ListTile(
                        leading: Icon(Icons.settings, color: Color.fromRGBO(198, 124, 78, 1)),
                        title: Text("Hesap Ayarları"),
                        trailing: Icon(Icons.arrow_right_sharp, color: Color.fromRGBO(198, 124, 78, 1))
                      ),
                      onTap: (){
                       Navigator.push(context, MaterialPageRoute(builder: (context)=> Accountsettings()));
                      },
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Adresspage()));
                      },
                      child: ListTile(
                        leading: Icon(Icons.home_filled, color: Color.fromRGBO(198, 124, 78, 1)),
                        title: Text("Adreslerim"),
                          trailing: Icon(Icons.arrow_right_sharp, color: Color.fromRGBO(198, 124, 78, 1)
                          )

                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Creditcardpage()));
                      },
                      child: ListTile(
                        leading: Icon(Icons.payment, color: Color.fromRGBO(198, 124, 78, 1)),
                        title: Text("Kartlarım"),
                          trailing: Icon(Icons.arrow_right_sharp, color:Color.fromRGBO(198, 124, 78, 1))

                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Orderhistory(userId: currentUser!.uid)));
                      },
                      child: ListTile(
                        leading: Icon(Icons.access_time_filled, color: Color.fromRGBO(198, 124, 78, 1)),
                        title: Text("Sipariş Geçmişi"),
                          trailing: Icon(Icons.arrow_right_sharp, color: Color.fromRGBO(198, 124, 78, 1))

                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          : // null kontrol
      Text("HATAA"),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromRGBO(255, 245, 238, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  FirebaseAuth.instance.signOut().then((deger){
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_)=> LoginRegisterPage()),
                            (Route<dynamic> route) => false);
                  });
                },
                style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(Color.fromRGBO(198, 124, 78, 1))
                ),
                child: Text("Çıkış Yap",style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),


    );

  }
}

