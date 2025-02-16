import 'package:coffee_shopp/classes/Adresses.dart';
import 'package:flutter/cupertino.dart';

class AdressesProvider extends ChangeNotifier {
  Adresses? _selectedAdress;
  Adresses? get selectedAdress => _selectedAdress;

  void setSelectedAdress(Adresses adress) { // widget ağacı tamamlandıktan sonra çalıştı
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedAdress = adress;
      notifyListeners();
    });
  }

}