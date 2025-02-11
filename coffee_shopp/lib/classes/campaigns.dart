class Campaigns{
  int campaigns_id;
  String campaignsName;
  String campaignsImageName;
  double campaignsValue;
  String campaignsexplanation;

  Campaigns({
    required this.campaigns_id,
    required this.campaignsName,
    required this.campaignsImageName,
    required this.campaignsValue,
    required this.campaignsexplanation});

  factory Campaigns.fromFirestore(Map<String, dynamic> doc){
    return Campaigns(
        campaigns_id: doc['campaigns_id'] != null ? doc['campaigns_id'] as int : 0,
        campaignsName: doc['campaignsName'] ?? 'No Name',
        campaignsImageName: doc['campaignsImageName'] ?? 'default.jpg',
      campaignsValue: (doc['campaignsValue'] != null)
          ? (doc['campaignsValue'] is int
          ? (doc['campaignsValue'] as int).toDouble()
          : doc['campaignsValue'] as double)
          : 0.0,
        campaignsexplanation: doc['campaignsexplanation'] ?? 'No Name',
    );
  }
}