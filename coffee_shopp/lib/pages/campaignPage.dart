import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../classes/campaigns.dart';
import '../widgets/availableTitle.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({super.key});

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  Future<List<Campaigns>> getCampaigns() async   {
    List<Campaigns> campaignList = [];

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Campaigns').get();
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

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
                          color: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Image Section
                              Container(
                                width: screenWidth * 0.28,
                                height: screenHeight * 0.12,
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: AssetImage("pictures/${camp.campaignsImageName}"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Details Section
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.02,
                                    horizontal: screenWidth * 0.02,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AvailableTitle(
                                                "${camp.campaignsexplanation}"
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
