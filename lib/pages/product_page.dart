import 'package:flutter/material.dart';
import 'package:pertemuan10_2306039/models/product_model.dart';
import 'package:pertemuan10_2306039/pages/product_detail.dart';
import 'package:pertemuan10_2306039/widgets/product_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<ProductModel> products = [];

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = prefs.getStringList('products') ?? [];
    setState(() {
      products = productList
          .map((item) => ProductModel.fromJson(item))
          .toList();
    });
  }

  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = products.map((item) => item.toJson()).toList();
    await prefs.setStringList('products', productList);
  }

  Future<void> addProduct(ProductModel product) async {
    setState(() {
      products.add(product);
    });
    await saveProducts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan')),
      );
    }
  }

  Future<void> updateProduct(int index, ProductModel updatedProduct) async {
    setState(() {
      products[index] = updatedProduct;
    });
    await saveProducts();
  }

  Future<void> deleteProduct(int index) async {
    setState(() {
      products.removeAt(index);
    });
    await saveProducts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus')),
      );
    }
  }

  void showForm({ProductModel? product, int? index}) {
    TextEditingController nameController = TextEditingController(
      text: product?.name ?? '',
    );
    TextEditingController descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    TextEditingController priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
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
            onPressed: () {
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
                description: descriptionController.text,
                price: parsedPrice,
              );
              if (product == null) {
                addProduct(newProduct);
              } else {
                updateProduct(index!, newProduct);
              }
              Navigator.pop(context);
            },
            child: Text(product == null ? 'Simpan' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("produk", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text('Belum ada produk'))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return ProductCard(
                          product: product,
                          onDelete: () => deleteProduct(index),
                          onEdit: () =>
                              showForm(product: product, index: index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
