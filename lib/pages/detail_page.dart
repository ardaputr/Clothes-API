import 'package:flutter/material.dart';
import '../models/clothing.dart';
import '../services/api_service.dart';
import 'create_edit_page.dart';

class DetailPage extends StatefulWidget {
  final int id;
  const DetailPage({super.key, required this.id});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Clothing> _clothingFuture;

  @override
  void initState() {
    super.initState();
    _loadClothing();
  }

  void _loadClothing() {
    _clothingFuture = ApiService.fetchClothingById(widget.id);
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus pakaian ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await ApiService.deleteClothing(widget.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pakaian berhasil dihapus')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
      }
    }
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pakaian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateEditPage(id: widget.id),
                ),
              );
              if (updated == true) {
                _loadClothing();
                setState(() {});
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Hapus',
            onPressed: _delete,
          ),
        ],
      ),
      body: FutureBuilder<Clothing>(
        future: _clothingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final clothing = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    Icons.checkroom,
                    size: 100,
                    color: Colors.blueAccent.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    clothing.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRow('Kategori', clothing.category),
                _buildRow('Harga', 'Rp ${clothing.price}'),
                _buildRow('Rating', clothing.rating.toString()),
                _buildRow('Brand', clothing.brand ?? '-'),
                _buildRow('Terjual', clothing.sold?.toString() ?? '-'),
                _buildRow('Stok', clothing.stock?.toString() ?? '-'),
                _buildRow(
                  'Tahun Rilis',
                  clothing.yearReleased?.toString() ?? '-',
                ),
                _buildRow('Material', clothing.material ?? '-'),
              ],
            ),
          );
        },
      ),
    );
  }
}
