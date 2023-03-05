import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Userdetailform extends StatefulWidget {
  const Userdetailform({Key? key}) : super(key: key);

  @override
  State<Userdetailform> createState() => _UserdetailformState();
}

class _UserdetailformState extends State<Userdetailform> {
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences prefs;

  TextEditingController collegenamecontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();

  Future<void> setup() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('formfilled', true);
      prefs.setBool('final', true);
    });
    print("//////////////////////////////formfilled");
  }

  Future<void> uploaddata(
      {required String collegename, required String phonenumct}) async {
    final User? user = FirebaseAuth.instance.currentUser;
    CollectionReference dusers = FirebaseFirestore.instance.collection('users');

    await dusers.doc(user?.email).set({
      'name': user?.displayName,
      'email': user?.email,
      'phone': user?.phoneNumber,
      'collegename': collegename,
      'phone': phonenumct,
      'formfilled': 'true',
    });
    await setup();

    Get.snackbar("done!", "Welcome to Codingzone",
        backgroundColor: Colors.green, colorText: Colors.black);
    Get.offAllNamed("/hm");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: collegenamecontroller,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.account_circle,
                          color: Colors.white,
                        ),
                        fillColor: Colors.black.withOpacity(0.6),
                        filled: true,
                        labelText: "Enter College Name",
                        labelStyle: const TextStyle(
                            color: Colors.white, fontSize: 16.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style:
                          const TextStyle(fontSize: 20.0, color: Colors.white),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Collage Name';
                        }
                        return null;
                      },
                    ),
                  ),

                  /////////////////////////

                  ////////////////////////////

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: phonecontroller,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                        fillColor: Colors.black.withOpacity(0.6),
                        filled: true,
                        labelText: "Enter phone",
                        labelStyle: const TextStyle(
                            color: Colors.white, fontSize: 16.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style:
                          const TextStyle(fontSize: 20.0, color: Colors.white),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter phone';
                        } else if (value.length != 10) {
                          return 'Enter valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  ///////////////////////

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: 120,
                      child: FloatingActionButton.extended(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await uploaddata(
                                collegename: collegenamecontroller.text.trim(),
                                phonenumct: phonecontroller.text.trim());
                          }
                        },
                        label: const Text("Submit"),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
