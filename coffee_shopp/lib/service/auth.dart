import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../classes/users.dart';

class Auth {

  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  final currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final _firebaseFirestore = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance;

  //Register
  Future<void> createUser({required String email, required String userName, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print("E-posta doğrulama bağlantısı gönderildi!");
      }

      await _firebaseFirestore.collection("Users").doc(userCredential.user!.uid).set({
        "email": email,
        "userName": userName,
      });
    } catch (e) {
      print("Hata: $e");
    }
  }


//Login
  //Login
  Future<void> signIn({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      // E-posta doğrulama kontrolü
      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        // Eğer e-posta doğrulanmamışsa, kullanıcıya bilgi ver
        print("E-posta doğrulamanızı yapmadınız. Lütfen doğrulama e-postasını kontrol edin.");
        return;
      }
    } catch (e) {
      print("Hata: $e");
    }
  }


//Sign out
  Future<void> singOut({required String email, required String password}) async{
    await _firebaseAuth.signOut();

  }

  Future<Users?> signInAnon() async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInAnonymously();
      if (userCredential.user != null) {
        // Anonim giriş yaptıktan sonra Users objesi oluşturuyoruz
        return Users(
            email: userCredential.user!.email ?? 'No Email',
            userName: 'Guest',
            isAnonymous: true,
            photoURL: 'defalt.png');

      }
    } catch (e) {
      print("Anonim giriş hatası: $e");
    }
    return null;
  }



  Future<Users?> getUserDetails() async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      // Kullanıcı oturum kontrolü
      if (currentUser == null) {
        print("Mevcut kullanıcı oturum açmamış.");
        return null;
      }

      // Anonim kullanıcı durumu
      if (currentUser.isAnonymous) {
        print("Anonim kullanıcı giriş yaptı. UID: ${currentUser.uid}");
        return Users(
            email: currentUser.email ?? "Anonim Kullanıcı",
            userName:  "Anonim Kullanıcı",
            isAnonymous: true,
            photoURL: 'default.png');
      }

      // Kalıcı kullanıcı durumu
      final snapshot = await _firebaseFirestore
          .collection("Users")
          .where("email", isEqualTo: currentUser.email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print("Firestore'da kullanıcı bulunamadı. Email: ${currentUser.email}");
        return null;
      }

      // Kullanıcı verilerini al
      final data = snapshot.docs.first.data();
      print("Firestore'dan alınan kullanıcı verisi: $data");

      // Kullanıcıyı modelle döndür
      return Users(
        email: data['email'] ?? 'No Email',  // Eğer null ise 'No Email' dön
        userName: data['userName'] ?? 'No Name',  // Eğer null ise 'No Name' dön
        isAnonymous: false,
        photoURL: data['photoURL'] ?? 'woman.png',  // Eğer null ise 'default.png' dön
      );
    } catch (e) {
      // Hata yönetimi
      print("Kullanıcı bilgileri alınırken hata oluştu: $e");
      return null;
    }
  }
  Future<void> updateUsers({required String userName}) async {
    final currentUser = _firebaseAuth.currentUser;
    await FirebaseFirestore.instance.collection('Users').doc(currentUser?.uid).update({'userName':userName});

}
  Future<String?> uploadProfilePicture(File imageFile) async {

    try {
      // Firebase Storage'a fotoğrafı yükleyin
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _firebaseStorage.ref().child('profile_pictures/$fileName');

      UploadTask uploadTask = storageRef.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      // Fotoğrafın URL'sini döndür
      String photoURL = await snapshot.ref.getDownloadURL();
      return photoURL;
    } catch (e) {
      print("Fotoğraf yüklenirken hata oluştu: $e");
      return null;
    }
  }



}




