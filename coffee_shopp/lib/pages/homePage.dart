
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shopp/widgets/coffee_card.dart';
import 'package:coffee_shopp/classes/coffees.dart';
import 'package:coffee_shopp/pages/custom_search_delegate.dart';
import 'package:coffee_shopp/classes/users.dart';
import 'package:coffee_shopp/service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late List<Coffees> allCoffee;
  List<Coffees>? filteredCoffeeList = [];
  @override
  void initState() {
    super.initState();
    getUser();  // Kullanıcı bilgisini al
    fetchCoffeeList();
    getCoffeeList().then((coffeeList) {
      setState(() {
        this.allCoffee = coffeeList;
        // filteredCoffeeList'i coffeeList ile doldur
        filteredCoffeeList = allCoffee;
      });
    });
  }

  //search işlemleri
  final TextEditingController searchController = TextEditingController();
  void _showSearchPage() {
    showSearch(context: context, delegate: CustomSearchDelegate(allCoffee: filteredCoffeeList!));
  }

  void filterCoffeeList(String searchTerm) {
    // searchTerm boş ise, tüm kahveleri göster
    if (searchTerm.isEmpty) {
      setState(() {
        // Tüm kahve listesini göster
        filteredCoffeeList = allCoffee;
      });
    } else {
      setState(() {
        // searchTerm içeren kahveleri filtrele ve göster
        filteredCoffeeList = allCoffee.where((coffee) =>
            coffee.coffeeName.toLowerCase().contains(searchTerm.toLowerCase()))
            .toList();
      });
    }
  }

  // Firebase'den kahve listesi almak için kullanılacak fonksiyon
  Future<void> fetchCoffeeList() async {
    allCoffee = await getCoffeeList();
    setState(() {});
  }




  //KAHVEMENUİSLEMLERİ
  var typesofcoffee = ["Cappucino", "Latte", "Machiato", "Espresso", "Americano"];
  String selectedCoffeeType = "Cappucino"; // Varsayılan seçili kahve türü


  Future<List<Coffees>> getCoffeeList({String? coffeeType}) async {
    List<Coffees> coffeeList = [];

    try {
      // Eğer coffeeType null ise, tüm kahveleri al
      final QuerySnapshot snapshot = coffeeType == null
          ? await FirebaseFirestore.instance.collection('Coffees').get()
          : await FirebaseFirestore.instance
          .collection('Coffees')
          .where('coffeeType', isEqualTo: coffeeType)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          print("Veri Çekildi: ${doc.data()}");
          coffeeList.add(Coffees.fromFirestore(doc.id,doc.data() as Map<String, dynamic>));
        }
      }
    } catch (e) {
      print("Hata: $e");
    }

    return coffeeList;
  }



  final Auth _auth = Auth();

  Users? user;  // Kullanıcı bilgisini tutacak değişken



  Future<void> getUser() async {
    try {
      final userDetails = await _auth.getUserDetails();
      setState(() {
        user = userDetails ??
            Users(email: 'No email',
                userName: 'No name',
                isAnonymous: true,
                photoURL: 'no photo');
            // Kullanıcı bilgisi yoksa varsayılan anonim kullanıcı

      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bir hata oluştu: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Ekran boyutuna göre farklı düzenlemeler yapılabilir.
    final bool isPortrait = screenWidth < screenHeight;

    return Scaffold(
      body: ListView(
        children: [
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Arka plan
                  Container(
                    width: screenWidth,
                    height: isPortrait ? screenHeight * 0.3 : screenHeight * 0.4, // Dikeyde küçük, yatayda büyük
                    color: Color.fromRGBO(19, 19, 19, 1),
                  ),
                  Positioned(
                    top: isPortrait ? screenHeight * 0.02 : screenHeight * 0.15, // Yatayda biraz daha yukarı
                    left: 10,
                    right: 10,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 5, left: 20),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: screenWidth * 0.87,
                                  child: TextField(
                                    onTap: (){
                                      _showSearchPage();
                                    },
                                    showCursor: false,
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Ara..',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      suffixIcon: Icon(Icons.search,color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white), // Alt çizgi rengi
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white), // Tıklandığında alt çizgi rengi
                                      ),
                                    ),
                                    onChanged: (value) {
                                      filterCoffeeList(value);
                                      _showSearchPage();

                                    },
                                  )),
                            ],
                          ),
                        ),
                        // Hoşgeldiniz metni ve görsel
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.09,
                            vertical: screenHeight * 0.01,
                          ),
                          child: SizedBox(
                            width: screenWidth * 0.8,
                            height: screenHeight * 0.1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Hoşgeldiniz mesajı
                              if(user != null)
                                Text(
                                  "Hoşgeldiniz, \n${user!.userName}",
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                )
                                else
                                  Text("Kullanıcı verisi alınamadı"),
                                // Görsel
                                if (user != null && user!.isAnonymous == false)
                                Image.asset(
                                  "pictures/${user?.photoURL}",
                                  width: screenWidth * 0.2,  // Yatayda görsel boyutunu küçültüyoruz
                                  height: screenHeight * 0.15,  // Yatayda görsel boyutunu küçültüyoruz
                                )
                                else if (user != null && user!.isAnonymous == true)
                                Icon(Icons.account_circle, size: 60,color: Color.fromRGBO(198, 124, 78, 1),)
                                else
                                  Text("Kullanıcı \nverisi alınamadı"),

                              ],
                            ),
                          ),
                        ),

                        Container(
                          width: screenWidth * 0.8,  // Görselin genişliği
                          height: isPortrait ? screenHeight * 0.16 : screenHeight * 0.25,  // Yatayda biraz daha büyük
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage("pictures/bigcappucino.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.1),
                child: SizedBox(
                  height: screenHeight * 0.06,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: typesofcoffee.length,
                      itemBuilder: (context, index){
                        final coffeeType = typesofcoffee[index];
                        final isSelected = coffeeType == selectedCoffeeType;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCoffeeType = coffeeType;
                            });
                          },
                          child: SizedBox(
                            width: screenWidth * 0.4,
                            child:
                            Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                            color: isSelected
                                ? Color.fromRGBO(198, 124, 78, 1)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            ),
                            child:  Center(
                              child: Text(
                                coffeeType,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Color.fromRGBO(198, 124, 78, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ),
                          )


                        );


                      }

                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.02),
                child: FutureBuilder<List<Coffees>>(
                  future: getCoffeeList(coffeeType: selectedCoffeeType),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Bir hata oluştu: ${snapshot.error}"),
                      );
                    } else if (snapshot.hasData) {
                      final coffeeList = snapshot.data ?? [];  // null kontrolü ile boş liste
                      if (coffeeList.isEmpty) {
                        return Center(
                          child: Text("Hiç kahve bulunamadı."),
                        );
                      } else {
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,  // İki sütunlu bir ızgara düzeni
                            crossAxisSpacing: 10.0,  // Sütunlar arasındaki mesafe
                            mainAxisSpacing: 10.0,   // Satırlar arasındaki mesafe
                            childAspectRatio:  screenWidth / (screenHeight * 0.65),  // Kart boyut oranı
                          ),
                          shrinkWrap: true, // GridView'in yüksekliğini sınırlamak için
                          physics: NeverScrollableScrollPhysics(), // Kaydırma engelleniyor
                          itemCount: coffeeList.length,
                          itemBuilder: (context, index) {
                            final coffee = coffeeList[index];
                            return CoffeeCard(coffee: coffee);
                          },
                        );
                      }
                    } else {
                      return Center(child: Text("Veri yok."));
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}


