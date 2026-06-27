import 'package:flutter/material.dart';
import 'package:pertemuan10_2306039/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  void _showAddProductForm() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  descriptionController.text.trim().isEmpty ||
                  priceController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Form ini wajib diisi')),
                );
                return;
              }
              int parsedPrice;
              try {
                parsedPrice = int.parse(priceController.text.trim());
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Harga harus berupa angka')),
                );
                return;
              }

              final newProduct = ProductModel(
                name: nameController.text,
                desc: descriptionController.text,
                price: parsedPrice,
                image: '',
              );

              final prefs = await SharedPreferences.getInstance();
              List<String> productList = prefs.getStringList('products') ?? [];
              productList.add(newProduct.toJson());
              await prefs.setStringList('products', productList);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produk berhasil ditambahkan')),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Produk")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.product.image.isNotEmpty
                ? Image.memory(
                    base64Decode(widget.product.image),
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 250),
            const SizedBox(height: 20),
            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Rp ${widget.product.price}"),
            const SizedBox(height: 10),
            Text(widget.product.desc),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductForm,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
