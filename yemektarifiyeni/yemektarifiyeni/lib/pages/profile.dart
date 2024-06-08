import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class Profile extends StatefulWidget {
  final String userName;

  const Profile({Key? key, required this.userName}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _user;
  Map<String, dynamic>? _userData;
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  String _bmiResult = '';

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>?;
          });
        } else {
          setState(() {
            _userData = {'error': 'User data not found in Firestore'};
          });
        }
      } catch (e) {
        setState(() {
          _userData = {'error': e.toString()};
        });
      }
    } else {
      setState(() {
        _userData = {'error': 'No user logged in'};
      });
    }
  }

  void _signOut() async {
    await _auth.signOut();
    SystemNavigator.pop(); // Uygulamadan çık
  }

  void _calculateBMI() {
    double height = double.parse(_heightController.text) / 100; // cm to meters
    double weight = double.parse(_weightController.text);
    double bmi = weight / (height * height);
    setState(() {
      _bmiResult = bmi.toStringAsFixed(1);
    });
  }

  String _interpretBMI(double bmi) {
    if (bmi < 18.5) {
      return 'Zayıf';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Fazla Kilolu';
    } else {
      return 'Obez';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: _userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade300,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 20),
            if (_userData!.containsKey('error'))
              Text(
                'Error: ${_userData!['error']}',
                style: TextStyle(fontSize: 18, color: Colors.red),
              )
            else
              Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.black, width: 1.5),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        'İsim: ${_userData!['isim']}',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.black, width: 1.5),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        'Email: ${_user!.email}',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Boy (cm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Kilo (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _calculateBMI();
                    },
                    child: Text('BMI Hesapla'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_bmiResult.isNotEmpty)
                    Text(
                      'BMI Sonucu: $_bmiResult - ${_interpretBMI(double.parse(_bmiResult))}',
                      style: TextStyle(fontSize: 18),
                    ),
                ],
              ),
            Spacer(),
            ElevatedButton(
              onPressed: _signOut,
              child: Text('Çıkış Yap', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
