

class Users {
  String email;
  String userName;
  bool isAnonymous;
  String? photoURL;
  Users({required this.email,required this.userName,this.isAnonymous = false,required this.photoURL});

  factory Users.fromFirestore(Map<String, dynamic> doc){
    return Users(
        email: doc['email'] ?? ['user@gmail.com'],
        userName: doc['userName'] ?? ['userName'],
        isAnonymous: false,
        photoURL: doc['photoURL'] ?? ['default.png'],
    );


  }

}
