import 'package:coffee_shopp/pages/login_register_page.dart';
import 'package:coffee_shopp/service/adressesProvider.dart';
import 'package:coffee_shopp/service/cartProvider.dart';
import 'package:coffee_shopp/service/creditCardsProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context)=> CartProvider()),
            ChangeNotifierProvider(create: (context) => CreditCardProvider()),
            ChangeNotifierProvider(create: (context) => AdressesProvider()),// CreditCardProvider'ı ekliyoruz
          ],
      child: MyApp(),
      ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWith = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ListView(
          scrollDirection: Axis.vertical,
        children:[
          Container(
            width: screenWith,
            height: screenHeight,
            child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'pictures/bigcoffee.png', // Resim dosyanızın yolu
                  fit: BoxFit.cover, // Ekranı tamamen kaplayacak şekilde ayarla
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.60),
                      child: Text(
                        "Her Yudumda\nTaze Başlangıç",
                        style: TextStyle(fontSize: 40, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                      child: ElevatedButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginRegisterPage()));
                      },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(198, 124, 78, 1),
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Başlayın")),
                    )
                  ],
                ),
              )
            ],
                    ),
          ),]
      ),


    );
  }
}
