import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemektarifiyeni/pages/details.dart';
import 'package:yemektarifiyeni/pages/seeall.dart';
import 'package:yemektarifiyeni/widget/widget_support.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _HomeState();
}

class _HomeState extends State<home> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yemek Tarifleri'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FoodSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategorySection(
              title: "Yemekler",
              collection: 'Yemekler',
              searchQuery: searchQuery,
            ),
            CategorySection(
              title: "corbalar",
              collection: 'corbalar',
              searchQuery: searchQuery,
            ),
            CategorySection(
              title: "salatalar",
              collection: 'salatalar',
              searchQuery: searchQuery,
            ),
            CategorySection(
              title: "tatlılar",
              collection: 'tatlılar',
              searchQuery: searchQuery,
            ),
          ],
        ),
      ),
    );
  }
}

class CategorySection extends StatefulWidget {
  final String title;
  final String collection;
  final String searchQuery;

  const CategorySection({
    Key? key,
    required this.title,
    required this.collection,
    required this.searchQuery,
  }) : super(key: key);

  @override
  _CategorySectionState createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
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
    if (widget.searchQuery.isNotEmpty) {
      query = query
          .where('YemekAd', isGreaterThanOrEqualTo: widget.searchQuery)
          .where('YemekAd', isLessThanOrEqualTo: widget.searchQuery + '\uf8ff');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: AppWidget.SemiBoldTextFeildStyle(),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeeAllPage(
                        category: widget.title,
                        collection: widget.collection,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Tümünü Gör',
                  style: AppWidget.SemiBoldTextFeildStyle().copyWith(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 250,
          child: StreamBuilder<QuerySnapshot>(
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

              return ListView.builder(
                scrollDirection: Axis.horizontal,
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
                          builder: (context) => DetailsPage(documentId: documentSnapshot.id, category: widget.title),
                        ),
                      );
                    },
                    child: Container(
                      width: 160,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 0),
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
        ),
      ],
    );
  }
}

class FoodSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Yemek ara';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return CategorySection(
      title: "Arama Sonuçları",
      collection: 'Yemekler',
      searchQuery: query,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return CategorySection(
      title: "Arama Sonuçları",
      collection: 'Yemekler',
      searchQuery: query,
    );
  }
}
