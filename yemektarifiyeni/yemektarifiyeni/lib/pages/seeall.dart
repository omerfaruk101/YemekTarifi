import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemektarifiyeni/pages/details.dart';
import 'package:yemektarifiyeni/widget/widget_support.dart';

class SeeAllPage extends StatefulWidget {
  final String category;
  final String collection;

  const SeeAllPage({
    Key? key,
    required this.category,
    required this.collection,
  }) : super(key: key);

  @override
  _SeeAllPageState createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> {
  Map<String, bool> savedStatuses = {};

  @override
  void initState() {
    super.initState();
    _fetchSavedStatuses();
  }

  Future<void> _fetchSavedStatuses() async {
    final snapshot = await FirebaseFirestore.instance.collection('Saved').get();
    final savedDocs = snapshot.docs;

    setState(() {
      for (var doc in savedDocs) {
        savedStatuses[doc['yemekId']] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection(widget.collection);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return Center(
              child: Text('Hata'),
            );
          }
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (asyncSnapshot.data == null || asyncSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Bu kategoride yemek bulunamadı.'),
            );
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.7,
            ),
            itemCount: asyncSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot documentSnapshot = asyncSnapshot.data!.docs[index];
              Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
              String yemekAd = data.containsKey('YemekAd') ? data['YemekAd'] : "İsimsiz Yemek";
              String resimUrl = data.containsKey('resim') ? data['resim'] : "https://via.placeholder.com/150"; // Placeholder resim
              bool isSaved = savedStatuses[documentSnapshot.id] ?? false;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsPage(documentId: documentSnapshot.id, category: widget.category),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            resimUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            yemekAd,
                            style: AppWidget.SemiBoldTextFeildStyle(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    savedStatuses[documentSnapshot.id] = !isSaved;
                                  });
                                  if (isSaved) {
                                    // Kaydedilenler listesinden çıkar
                                    QuerySnapshot savedSnapshot = await FirebaseFirestore.instance
                                        .collection('Saved')
                                        .where('yemekId', isEqualTo: documentSnapshot.id)
                                        .get();
                                    for (var doc in savedSnapshot.docs) {
                                      await doc.reference.delete();
                                    }
                                  } else {
                                    // Kaydet
                                    await FirebaseFirestore.instance.collection('Saved').add({
                                      'yemekId': documentSnapshot.id,
                                      'category': widget.collection,
                                    });
                                  }
                                },
                                child: Icon(
                                  isSaved ? Icons.favorite : Icons.favorite_border,
                                  color: isSaved ? Colors.red : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
