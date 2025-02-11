
import 'package:coffee_shopp/pages/navigationBar.dart';
import 'package:coffee_shopp/classes/users.dart';
import 'package:coffee_shopp/service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_text_form_field.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  bool isLogin = true;

  final Auth _auth = Auth();


  Future<void> createUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.createUser(
          email: emailController.text,
          userName: usernameController.text,
          password: passwordController.text,
        );

        // Kullanıcı oluşturulduktan sonra doğrulama e-postası gönder
        User? user = FirebaseAuth.instance.currentUser;
        await user?.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Doğrulama e-postası gönderildi! Lütfen e-postanızı kontrol edin.")),
        );

      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Bir hata oluştu.")));
      }
    }
  }


  Future<void> signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Firebase Authentication ile giriş yap
        await _auth.signIn(
          email: emailController.text,
          password: passwordController.text,
        );

        // Firestore'dan kullanıcı bilgilerini al
        final userDetails = await _auth.getUserDetails();

        // E-posta doğrulaması yapılmış mı kontrol et
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null && !user.emailVerified) {
          // E-posta doğrulaması yapılmamışsa, kullanıcıyı bilgilendir
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lütfen e-posta adresinizi doğrulayın.")),
          );
          return;
        }

        if (userDetails != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarMenu(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kullanıcı bilgileri alınamadı!")),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            e.code == "user-not-found"
                ? "Bu e-posta ile kayıtlı kullanıcı bulunamadı."
                : e.code == "wrong-password"
                ? "Hatalı şifre."
                : e.code == "invalid-email"
                ? "Geçersiz e-posta adresi."
                : "Bir hata oluştu.",
          ),
        ));
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.1,
              right: screenWidth * 0.10,
              left: screenWidth * 0.10,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isLogin)
                    Column(
                      children: [
                        CustomTextFormField(
                          controller: emailController,
                          hintText: "Email",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "E-posta alanı boş olamaz.";
                            } else if (RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$").hasMatch(value)) {
                              return "Geçerli bir e-posta adresi girin.";
                            }
                            return null;
                          },

                        ),
                        CustomTextFormField(
                          controller: passwordController,
                          hintText: "Şifre",
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Şifre alanı boş olamaz.";
                            } else if (value.length < 6) {
                              return "Şifre en az 6 karakter olmalıdır.";
                            }
                            return null;
                          },
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        CustomTextFormField(
                          controller: emailController,
                          hintText: "Email",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "E-posta alanı boş olamaz.";
                            } else if (RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$").hasMatch(value)) {
                              return "Geçerli bir e-posta adresi girin.";
                            }
                            return null;
                          },
                        ),
                        CustomTextFormField(
                          controller: usernameController,
                          hintText: "Kullanıcı Adı",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Kullanıcı adı boş olamaz.";
                            }
                            return null;
                          },
                        ),
                        CustomTextFormField(
                          controller: passwordController,
                          hintText: "Şifre",
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Şifre alanı boş olamaz.";
                            } else if (value.length < 6) {
                              return "Şifre en az 6 karakter olmalıdır.";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  SizedBox(height: screenHeight * 0.06),
                  ElevatedButton(
                    onPressed: () {
                      if (isLogin) {
                        signIn();
                      } else {
                        createUser();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(198, 124, 78, 1),
                      foregroundColor: Colors.white,
                    ),
                    child: isLogin ? const Text("Giriş Yap") : const Text("Kayıt OL"),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLogin = !isLogin;
                        _formKey.currentState?.reset();
                        emailController.clear();
                        passwordController.clear();
                        usernameController.clear();
                      });
                    },
                    child: isLogin
                        ? Text("Henüz bir hesabınız yok mu? Tıklayın.")
                        : Text("Zaten bir hesabınız varsa giriş yapın."),
                  ),
                  SizedBox(height: screenHeight * 0.4),
                  ElevatedButton(
                    onPressed: () async {
                      Users? user = await Auth().signInAnon();
                      if (user != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BarMenu(),
                          ),
                        );
                      } else {
                        print("Anonim giriş başarısız.");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(198, 124, 78, 1),
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Misafir Girişi"),
                  ),


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
