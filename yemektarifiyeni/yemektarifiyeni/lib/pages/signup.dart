import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yemektarifiyeni/widget/widget_support.dart';
import 'package:yemektarifiyeni/pages/bottomnav.dart';
import 'package:yemektarifiyeni/pages/login.dart';
import 'package:yemektarifiyeni/service/database.dart';
import 'package:yemektarifiyeni/service/shared_pref.dart';
import 'package:random_string/random_string.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "";

  TextEditingController namecontroller = new TextEditingController();

  TextEditingController passwordcontroller = new TextEditingController();

  TextEditingController mailcontroller = new TextEditingController();

  final _formkey = GlobalKey<FormState>();

  Future<void> signUp() async {
  // Alanların boş olup olmadığını ve şifrelerin uygunluğunu kontrol et
  if (namecontroller.text.isEmpty ||
      mailcontroller.text.isEmpty ||
      passwordcontroller.text.isEmpty ) {
    // Boş alan varsa hata mesajı göster
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hata!'),
          content: Text('Lütfen tüm alanları doldurun.'),
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        );
      },
    );
    return;
  }

  // Kullanıcıyı kaydet
  try {
    var user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: mailcontroller.text.trim(),
      password: passwordcontroller.text.trim(),
    );

    await FirebaseFirestore.instance.collection('users').doc(user.user?.uid).set({
      'isim': namecontroller.text.trim(),
      'eposta': mailcontroller.text.trim(),
    });
  } catch (error) {
    // Hata durumunda genel hata mesajı göster
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hata!'),
          content: Text('Bir hata oluştu. Lütfen tekrar deneyin.'),
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        );
      },
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.5,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                        Color(0xFFff5c30),
                        Color(0xFFe74b1a),
                      ])),
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40))),
                  child: Text(""),
                ),
                Container(
                  margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
                  child: Column(
                    children: [
                      Center(
                          child: Image.asset(
                        "assets/images/logo.png",
                        width: MediaQuery.of(context).size.width / 1.5,
                        fit: BoxFit.cover,
                      )),
                      SizedBox(
                        height: 50.0,
                      ),
                      Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 1.8,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Form(
                            key: _formkey,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 30.0,
                                ),
                                Text(
                                  "Kayıt Ol",
                                  style: AppWidget.HeadlineTextFeildStyle(),
                                ),
                                SizedBox(
                                  height: 30.0,
                                ),
                                TextFormField(
                                  controller: namecontroller,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen isim giriniz';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      hintText: 'İsim',
                                      hintStyle: AppWidget.SemiBoldTextFeildStyle(),
                                      prefixIcon: Icon(Icons.person_outlined)),
                                ),
                                SizedBox(
                                  height: 30.0,
                                ),
                                TextFormField(
                                  controller: mailcontroller,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen Email giriniz';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: AppWidget.SemiBoldTextFeildStyle(),
                                      prefixIcon: Icon(Icons.email_outlined)),
                                ),
                                SizedBox(
                                  height: 30.0,
                                ),
                                TextFormField(
                                  controller: passwordcontroller,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen Şifre Girin';
                                    }
                                    return null;
                                  },
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      hintText: 'Şifre',
                                      hintStyle: AppWidget.SemiBoldTextFeildStyle(),
                                      prefixIcon: Icon(Icons.password_outlined)),
                                ),
                                SizedBox(
                                  height: 30.0,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (_formkey.currentState!.validate()) {
                                      setState(() {
                                        email = mailcontroller.text;
                                        name = namecontroller.text;
                                        password = passwordcontroller.text;
                                      });
                                    }
                                    signUp();
                                  },
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 8.0),
                                      width: 200,
                                      decoration: BoxDecoration(
                                          color: Color(0Xffff5722),
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Center(
                                          child: Text(
                                        "Kayıt Ol",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontFamily: 'Poppins1',
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => LogIn()));
                          },
                          child: Text(
                            "Hesabın var mı? Giriş Yap",
                            style: AppWidget.SemiBoldTextFeildStyle(),
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}