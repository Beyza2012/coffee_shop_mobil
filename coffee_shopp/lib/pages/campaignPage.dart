import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../classes/campaigns.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({super.key});

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  Future<List<Campaigns>> getCampaigns() async   {
  List<Campaigns> campaignList = [];

    try {
   final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Campaign').get();
   if (snapshot.docs.isNotEmpty) {
   for (var doc in snapshot.docs) {
     print("Veri Çekildi: ${doc.data()}");
     campaignList.add(Campaigns.fromFirestore(doc.data() as Map<String, dynamic>));
   }
   }
  }catch(e){
      print("Hata: ${e}");
  }
  return campaignList;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kampanyalar'),
        automaticallyImplyLeading: false, // Geri butonunu kaldırır
        centerTitle: true, // Başlık metnini ortalar
      ),
      body: Column(
        children: [
          SizedBox(
            width: 500,
            child: FutureBuilder<List<Campaigns>>(
              future: getCampaigns(),
              builder: (context,snapshot) {
                if(snapshot.hasData){
                  var campList = snapshot.data;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: campList!.length,
                    itemBuilder: (context,index) {
                      var camp = campList[index];
                      return
                        Card(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white38,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: 100,
                                height:100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: AssetImage("pictures/${camp.campaignsImageName}"), fit:BoxFit.fill,
                                  ),
                                ),

                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        width: 120,
                                        child: Text("${camp.campaignsexplanation}")
                                      ),
                                    ],
                                  ),
                                ],

                              )
                            ],
                          ),
                        ),
                      );
                    } ,
                  );
                }else {
                  return Center(child: Text(
                    'Kampanya bulunmuyor.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  );
                }
              },
            ),
          ),

        ],
      ),

    );
  }
}
