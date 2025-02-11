class Coffees {
  String? coffeeId;
  String coffeeName;
  String coffeeType;
  String imageName;
  int point;
  int price;
  String shoutOrMilk;

  Coffees({
     this.coffeeId,
    required this.coffeeName,
    required this.coffeeType,
    required this.imageName,
    required this.point,
    required this.price,
    required this.shoutOrMilk,
  });

  factory Coffees.fromFirestore(String id , Map<String, dynamic> doc) {
    return Coffees(
      coffeeId: id,
      coffeeName: doc['coffeeName'] ?? 'No Name',
      coffeeType: doc['coffeeType'] ?? 'No Type',
      shoutOrMilk: doc['shoutOrMilk'] ?? 'No Milk',
      imageName: doc['imageName'] ?? 'default.jpg',
      point: (doc['point'] is int) ? doc['point'] : int.tryParse(doc['point'].toString()) ?? 0,  // int tipinde alıyoruz
      price: (doc['price'] is int) ? doc['price'] : int.tryParse(doc['price'].toString()) ?? 0,  // int tipinde alıyoruz
    );
  }
}
