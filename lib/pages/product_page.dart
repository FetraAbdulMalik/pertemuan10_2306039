import 'package:flutter/material.dart';
import 'package:pertemuan10_2306039/models/product_model.dart';
import 'package:pertemuan10_2306039/widgets/product_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

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

  Future<String> convertImageToBase64(XFile image) async {
    Uint8List bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  void showForm({ProductModel? product, int? index}) {
    TextEditingController nameController = TextEditingController(
      text: product?.name ?? '',
    );
    TextEditingController descController = TextEditingController(
      text: product?.desc ?? '',
    );
    TextEditingController priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    TextEditingController imgController = TextEditingController(
      text: product?.image ?? "",
    );

    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    Future<void> pickImage(StateSetter setDialogState) async {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setDialogState(() {
          selectedImage = image;
          imgController.text = image.path;
        });
      }
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          Widget buildPreviewImage() {
            if (selectedImage != null) {
              return FutureBuilder<Uint8List>(
                future: selectedImage!.readAsBytes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return Image.memory(
                    snapshot.data!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  );
                },
              );
            }

            if (product?.image.isNotEmpty ?? false) {
              return Image.memory(
                base64Decode(product!.image),
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              );
            }

            return const SizedBox.shrink();
          }

          return AlertDialog(
            title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Harga'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => pickImage(setState),
                    icon: const Icon(Icons.image),
                    label: const Text("Pilih Gambar"),
                  ),
                  const SizedBox(height: 10),
                  buildPreviewImage(),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty ||
                      descController.text.trim().isEmpty ||
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

                  String imageBase64 = product?.image ?? "";
                  if (selectedImage != null) {
                    imageBase64 = await convertImageToBase64(selectedImage!);
                  }

                  final newProduct = ProductModel(
                    name: nameController.text,
                    desc: descController.text,
                    price: parsedPrice,
                    image: imageBase64,
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
          );
        },
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
