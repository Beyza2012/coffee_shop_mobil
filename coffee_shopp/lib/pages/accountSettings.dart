import 'package:coffee_shopp/classes/Adresses.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../classes/users.dart';
import '../service/auth.dart';
import '../widgets/custom_text_form_field.dart';

class Accountsettings extends StatefulWidget {
  const Accountsettings({super.key});

  @override
  State<Accountsettings> createState() => _AccountsettingsState();
}

class _AccountsettingsState extends State<Accountsettings> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  Users? user;
  final Auth _auth = Auth();

  Future<void> updateUsers() async {
    if (_formKey.currentState!.validate()){
      try{
        await _auth.updateUsers(userName: usernameController.text);
        print("güncellendi");
      }catch(e){print(e);}
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Güncelle başarısız!")),
      );

    }
  }
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
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Hesap Ayarlarım", style: TextStyle(fontSize: 25, color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if(user != null)
          Padding(
          padding: EdgeInsets.only(
          top: screenHeight * 0.1,
          right: screenWidth * 0.10,
          left: screenWidth * 0.10,),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.mail_outline_outlined, color: Color.fromRGBO(198, 124, 78, 1),size: 30,),
                      SizedBox(
                        width: screenWidth * 0.7,
                        child: AbsorbPointer(
                          child: CustomTextFormField(
                            controller: emailController,
                            hintText: "${user!.email}",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.account_circle_outlined, color: Color.fromRGBO(198, 124, 78, 1),size: 30,),
                      SizedBox(
                        width: screenWidth * 0.7,
                        child: CustomTextFormField(
                          controller: usernameController,
                          hintText: "${user!.userName}",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Kullanıcı adı boş olamaz.";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ) else Text("Kullanıcı bilgisi alınamadı")
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
                  updateUsers();
                },
                style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(Color.fromRGBO(198, 124, 78, 1))
                ),
                child: Text("Güncelle ",style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
