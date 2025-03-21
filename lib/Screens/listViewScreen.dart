import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giuaki/Screens/editProduct.dart';
import 'package:giuaki/service/productService.dart';

class ListViewScreen extends StatefulWidget {
  const ListViewScreen({super.key});

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  final productService _productService = productService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _deleteProduct(String id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa sản phẩm này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), 
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), 
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _productService.deleteProduct(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sản phẩm đã được xóa")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách sản phẩm"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Tìm kiếm sản phẩm...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _productService.getFilteredProducts(_searchQuery),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không có sản phẩm nào"));
          }

          var filteredProducts = snapshot.data!;

          return ListView.builder(
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              var productDoc = filteredProducts[index];
              var product = productDoc.data() as Map<String, dynamic>;
              String productId = productDoc.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(product["name"] ?? "Không có tên"),
                  subtitle: Text(
                      "Giá: ${product["price"] ?? "Không có"}\nDanh mục: ${product["category"] ?? "Không có"}",
                    ),
                  leading: product["imageUrl"] != null && product["imageUrl"].isNotEmpty
                      ? Image.network(
                          product["imageUrl"],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 50),
                        )
                      : const Icon(Icons.shopping_bag, size: 50),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProductScreen(productId: productId),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(productId),
                      ),
                    ],
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
