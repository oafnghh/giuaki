import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giuaki/service/productService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:giuaki/API/ImgBB.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final productService _productService = productService();
  final ImgBB imgBB = ImgBB();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  bool _isLoading = true;
  String? imageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    try {
      Map<String, dynamic>? product =
          await _productService.getProductById(widget.productId);
          print(product );
      if (product != null) {
        nameController.text     = product['name'];
        priceController.text    = product['price'];
        categoryController.text = product['category'];
        imageUrl                = product['imageUrl'];
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProduct() async {
    String name = nameController.text.trim();
    String price = priceController.text.trim();
    String category = categoryController.text.trim();

    if (name.isEmpty || price.isEmpty || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    String? newImageUrl = imageUrl;
    if (_imageFile != null) {
      String? uploadedUrl = await imgBB.uploadToImgur(_imageFile!);
      if (uploadedUrl != null) {
        newImageUrl = uploadedUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi tải ảnh lên ImgBB')),
        );
        return;
      }
    }

    await _productService.updateProduct(widget.productId, {
      'name': name,
      'price': price,
      'category': category,
      'imageUrl': newImageUrl ?? '',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cập nhật sản phẩm thành công')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa sản phẩm')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Giá sản phẩm'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Loại sản phẩm'),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                          _imageFile != null
                            ? Image.file(_imageFile!, width: 100, height: 100, fit: BoxFit.cover)
                            : (imageUrl != null && imageUrl!.isNotEmpty
                                ? Image.network(imageUrl!, width: 100, height: 100, fit: BoxFit.cover)
                                : Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 50),
                                  )),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Chọn ảnh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _updateProduct,
                    child: const Text('Cập nhật'),
                  ),
                ],
              ),
            ),
    );
  }
}
