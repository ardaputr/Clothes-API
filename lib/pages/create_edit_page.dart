import 'package:flutter/material.dart';
import '../models/clothing.dart';
import '../services/api_service.dart';

class CreateEditPage extends StatefulWidget {
  final int? id;
  const CreateEditPage({super.key, this.id});

  @override
  State<CreateEditPage> createState() => _CreateEditPageState();
}

class _CreateEditPageState extends State<CreateEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool isEditMode = false;

  // Controller form
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _soldController = TextEditingController();
  final _ratingController = TextEditingController();
  final _stockController = TextEditingController();
  final _yearReleasedController = TextEditingController();
  final _materialController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.id != null;
    if (isEditMode) {
      _loadData();
    }
  }

  void _loadData() async {
    setState(() => _loading = true);
    try {
      final clothing = await ApiService.fetchClothingById(widget.id!);
      _nameController.text = clothing.name;
      _priceController.text = clothing.price.toString();
      _categoryController.text = clothing.category;
      _brandController.text = clothing.brand ?? '';
      _soldController.text = clothing.sold?.toString() ?? '';
      _ratingController.text = clothing.rating.toString();
      _stockController.text = clothing.stock?.toString() ?? '';
      _yearReleasedController.text = clothing.yearReleased?.toString() ?? '';
      _materialController.text = clothing.material ?? '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error load data: $e')));
      }
    }
    setState(() => _loading = false);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final clothing = Clothing(
      name: _nameController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      category: _categoryController.text.trim(),
      brand:
          _brandController.text.trim().isEmpty
              ? null
              : _brandController.text.trim(),
      sold:
          _soldController.text.trim().isEmpty
              ? null
              : int.parse(_soldController.text.trim()),
      rating: double.parse(_ratingController.text.trim()),
      stock:
          _stockController.text.trim().isEmpty
              ? null
              : int.parse(_stockController.text.trim()),
      yearReleased:
          _yearReleasedController.text.trim().isEmpty
              ? null
              : int.parse(_yearReleasedController.text.trim()),
      material:
          _materialController.text.trim().isEmpty
              ? null
              : _materialController.text.trim(),
    );

    setState(() => _loading = true);

    try {
      if (isEditMode) {
        await ApiService.updateClothing(widget.id!, clothing);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pakaian berhasil diperbarui')),
          );
        }
      } else {
        await ApiService.createClothing(clothing);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pakaian berhasil ditambahkan')),
          );
        }
      }
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal submit: $e')));
      }
    }

    setState(() => _loading = false);
  }

  String? _validateRequired(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Field tidak boleh kosong';
    }
    return null;
  }

  String? _validateInt(String? val) {
    if (val == null || val.trim().isEmpty) return 'Field tidak boleh kosong';
    final n = int.tryParse(val.trim());
    if (n == null) return 'Harus berupa angka bulat';
    return null;
  }

  String? _validateDoubleRating(String? val) {
    if (val == null || val.trim().isEmpty) return 'Field tidak boleh kosong';
    final d = double.tryParse(val.trim());
    if (d == null) return 'Harus berupa angka desimal';
    if (d < 0 || d > 5) return 'Rating harus antara 0 dan 5';
    return null;
  }

  String? _validateYear(String? val) {
    if (val == null || val.trim().isEmpty) return 'Field tidak boleh kosong';
    final y = int.tryParse(val.trim());
    if (y == null) return 'Harus berupa angka';
    if (y < 2018 || y > 2025) return 'Tahun rilis harus antara 2018 dan 2025';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Pakaian' : 'Tambah Pakaian'),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nama'),
                        validator: _validateRequired,
                      ),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Harga'),
                        keyboardType: TextInputType.number,
                        validator: _validateInt,
                      ),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                        ),
                        validator: _validateRequired,
                      ),
                      TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(
                          labelText: 'Brand (opsional)',
                        ),
                      ),
                      TextFormField(
                        controller: _soldController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Terjual (opsional)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        controller: _ratingController,
                        decoration: const InputDecoration(labelText: 'Rating'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validateDoubleRating,
                      ),
                      TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(labelText: 'Stok'),
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        controller: _yearReleasedController,
                        decoration: const InputDecoration(
                          labelText: 'Tahun Rilis',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val != null && val.trim().isNotEmpty) {
                            return _validateYear(val);
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _materialController,
                        decoration: const InputDecoration(
                          labelText: 'Material',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text(
                          isEditMode ? 'Simpan Perubahan' : 'Tambah Pakaian',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
