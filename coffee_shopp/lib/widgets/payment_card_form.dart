import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'availableTitle.dart';
import 'custom_dropdownbuttonfield.dart';
import 'custom_text_form_field.dart';

class PaymentCardForm extends StatefulWidget {

  @override
  State<PaymentCardForm> createState() => _PaymentCardFormState();
}

class _PaymentCardFormState extends State<PaymentCardForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController cardNameController = TextEditingController();

  final TextEditingController cardNoController = TextEditingController();

  final TextEditingController monthController = TextEditingController();

  final TextEditingController yearController = TextEditingController();

  final TextEditingController cvvController = TextEditingController();

  final TextEditingController holderNameController = TextEditingController();

  final List<String> months = List.generate(12, (index) => (index + 1).toString());

  final List<String> years = List.generate(10, (index) => (DateTime.now().year + index).toString());

  final currentUser = FirebaseAuth.instance.currentUser;
  bool saveCard = false;


  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.02,
                      right: screenWidth * 0.10,
                      left: screenWidth * 0.10,
                      bottom: screenWidth * 0.02,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AvailableTitle("Kart Bilgileri"),
                      ],
                    ),
                  ),
                  Divider(
                    color: Color.fromRGBO(198, 124, 78, 1), // Çizgi rengi
                    thickness: 2,       // Kalınlık
                    indent: 20,         // Soldan boşluk
                    endIndent: 20,      // Sağdan boşluk
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.02,
                      right: screenWidth * 0.10,
                      left: screenWidth * 0.10,
                      bottom: screenWidth * 0.05,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextFormField(
                            controller: cardNameController,
                            hintText: "Kart Adı",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Bir kart adı girin.";
                              } else {
                                return null;}
                            },
                          ),
                          SizedBox(height: 16),
                          CustomTextFormField(
                            controller: cardNoController,
                            hintText: "Kart Numarası",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Bir kart numarası girin.";
                              } else {return null;}
                            },
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right:screenWidth * 0.03 ),
                                  child: CustomDropdownFormField(
                                    controller: monthController,
                                    hintText:"Ay",
                                    items: months,
                                    onChanged: (selectedMonth) {
                                      // Seçilen ay controller'a aktarılır
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Ay seçimi zorunludur.";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: screenWidth * 0.03 ),
                                  child: CustomDropdownFormField(
                                    controller: yearController,
                                    hintText: "Yıl",
                                    items: years,
                                    onChanged: (selectedYear) {
                                      // Seçilen yıl controller'a aktarılır
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Yıl seçimi zorunludur.";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          CustomTextFormField(
                            controller: cvvController,
                            hintText: "CVV",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "CVV girin.";
                              } else {return null;}
                            },
                          ),
                          SizedBox(height: 16),
                          CustomTextFormField(
                            controller: holderNameController,
                            hintText: "Kart Üzrindeki İsim",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Bir isim girin.";
                              } else {
                                return null;}
                            },
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: saveCard,
                                onChanged: (bool? value) {
                                  setState(() {
                                    saveCard = value ?? false;
                                  });
                                },
                              ),
                              Text("Kartı Kaydet"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
        ),


      ],
    );
  }
}
