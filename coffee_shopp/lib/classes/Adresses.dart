class Adresses{
  String? id;
  String title;
  String addressLine;
  String city;
  String postalCode;
  bool? selected;

  Adresses({this.id ,required this.title, required this.addressLine, required this.city, required this.postalCode, this.selected});

  factory Adresses.fromFirestore(String id, Map<String, dynamic> doc){
    return Adresses(
        id: id,
        title: doc['title'] ?? '',
        addressLine: doc['addressLine'] ?? '',
        city: doc['city'] ?? '',
        postalCode: doc['postalCode'] ?? '',
       selected: doc['selected'] ?? false,
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'addressLine': addressLine,
      'city': city,
      'postalCode': postalCode,
      'selected' : selected,
    };
  }

}

