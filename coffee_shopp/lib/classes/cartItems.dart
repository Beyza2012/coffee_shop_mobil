class CartItems {
  String coffeeId;
  String coffeeName;
  String shoutOrMilk;
  int quantity;
  String imageName;
  int price;
  int totalPrice;
  double? finalTotalPrice;

  CartItems({
    required this.coffeeId,
    required this.coffeeName,
    required this.shoutOrMilk,
    required this.quantity,
    required this.imageName,
    required this.price,
    required this.totalPrice,
    this.finalTotalPrice,
  });

  factory CartItems.fromFirestore(Map<String, dynamic> doc) {
    return CartItems(
      coffeeId: doc['coffeeId'] ?? 'No Id',
      coffeeName: doc['coffeeName'] ?? 'Unknown Coffee',
      shoutOrMilk: doc['shoutOrMilk'] ?? '',
      quantity: doc['quantity'] ?? 0,
      imageName:  doc['imageName'] ?? '',
      price: doc['price'] ?? 0,
      totalPrice: (doc['price'] ?? 0) * (doc['quantity'] ?? 0),
      finalTotalPrice: null, // Başlangıçta null olabilir
    );
  }
  // Firestore'a eklemek için veriyi dönüştüren metod
  Map<String, dynamic> toFirestore() {
    final data = {
      'coffeeId': coffeeId,
      'coffeeName': coffeeName,
      'shoutOrMilk': shoutOrMilk,
      'quantity': quantity,
      'imageName': imageName,
      'price': price,
      'totalPrice': totalPrice,
    };

    // Eğer finalTotalPrice null değilse ekleyelim
    if (finalTotalPrice != null) {
      data['finalTotalPrice'] = finalTotalPrice as Object;
    }

    return data;
  }
}

