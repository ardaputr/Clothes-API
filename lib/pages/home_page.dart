import 'package:flutter/material.dart';
import '../models/clothing.dart';
import '../services/api_service.dart';
import 'detail_page.dart';
import 'create_edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Clothing>> _clothesFuture;

  @override
  void initState() {
    super.initState();
    _loadClothes();
  }

  void _loadClothes() {
    _clothesFuture = ApiService.fetchAllClothes();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadClothes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pakaian')),
      body: FutureBuilder<List<Clothing>>(
        future: _clothesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Data kosong'));
          }

          final clothes = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: clothes.length,
              itemBuilder: (context, index) {
                final item = clothes[index];
                return GestureDetector(
                  onTap: () async {
                    final needRefresh = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(id: item.id!),
                      ),
                    );
                    if (needRefresh == true) {
                      _refresh();
                    }
                  },
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Center(
                              child: Icon(
                                Icons.checkroom,
                                size: 64,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Category: ${item.category}'),
                          Text('Price: Rp ${item.price}'),
                          Text('Rating: ${item.rating}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateEditPage()),
          );
          if (added == true) {
            _refresh();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
