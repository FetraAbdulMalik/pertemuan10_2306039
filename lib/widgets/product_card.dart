import 'package:flutter/material.dart';
import 'package:pertemuan10_2306039/models/product_model.dart';
import 'package:pertemuan10_2306039/pages/product_detail.dart';
import 'dart:convert';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  //constraktor
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          product.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onTap: onTap ??
            () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(product: product),
                  ),
                ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            product.image.isNotEmpty
                ? Image.memory(
                    base64Decode(product.image),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 120),
            const SizedBox(height: 4),
            Text(product.desc),
            const SizedBox(height: 8),
            Text('Harga: Rp ${product.price}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: () => onEdit!(),
              ),
            const SizedBox(width: 10),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete!(),
              ),
          ],
        ),
      ),
    );
  }
}
