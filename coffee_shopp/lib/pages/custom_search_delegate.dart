import 'package:coffee_shopp/widgets/availableTitle.dart';
import 'package:coffee_shopp/widgets/coffee_card.dart';
import 'package:flutter/material.dart';

import '../classes/coffees.dart';
import '../widgets/ availableText.dart';
class CustomSearchDelegate extends SearchDelegate{
  final List<Coffees> allCoffee;

  CustomSearchDelegate({required this.allCoffee});




  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: (){
        query.isEmpty ? null : query = '';

      }, icon: const Icon(Icons.clear)),
    ];

  }

  @override
  Widget? buildLeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: GestureDetector(
            onTap: (){
              close(context, null);
            },
            child: const Icon(Icons.arrow_back_ios,color: Colors.black,size: 15)),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Coffees> filteredCoffee = allCoffee
        .where((element) => element.coffeeName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return filteredCoffee.isNotEmpty
        ? GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Bir satırdaki öğe sayısı
          childAspectRatio: 0.7,
          crossAxisSpacing: 8.0, // Yatayda öğeler arası boşluk
          mainAxisSpacing: 8.0, // Dikeyde öğeler arası boşluk
        ),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: filteredCoffee.length,
        itemBuilder: (context, index) {
          var coffee = filteredCoffee[index];
          return GestureDetector(
            onTap: () {

            },
            child: CoffeeCard(coffee: coffee)
          );
        })
        : Container(
      child: Center(child: Text("Arama bulunamadı")),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Eğer arama çubuğu boşsa, puanı 8'den büyük olanları listele
    List<Coffees> recommendedCoffee;
    if(query.isEmpty){
      recommendedCoffee = allCoffee
          .where((element) => element.point > 8)
          .toList()
        ..sort((a, b) => b.point.compareTo(a.point));
    }

        else{
      recommendedCoffee = allCoffee
          .where((element) =>
          element.coffeeName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    return recommendedCoffee.isNotEmpty
        ?
    Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10,left: 1),
          child: Column(
            children: [
              AvailableText("En yüksek puanlılar"),
              Divider(
                color: Color.fromRGBO(198, 124, 78, 1), // Çizgi rengi
                thickness: 2,       // Kalınlık
                indent: 20,         // Soldan boşluk
                endIndent: 20,      // Sağdan boşluk
              ),
            ],
          ),
        ),

        SizedBox(
          height: 300,
          child: ListView.builder(
              itemCount: recommendedCoffee.length,
              itemBuilder: (context,index){
                var coffee = recommendedCoffee[index];
                return Dismissible(
                  key: Key(coffee.coffeeName),
                  child: ListTile(
                    title: AvailableTitle(coffee.coffeeName),
                    onTap: () {
                      query = coffee.coffeeName;
                      showResults(context);
                    },
                  ),
                );
              }),
        ),
      ],
    ) : Container();
  }
  @override
  TextInputType get keyboardType => TextInputType.text;

  @override
  String get searchFieldLabel => 'Ara..';  // Setting the placeholder to "Ara"


}