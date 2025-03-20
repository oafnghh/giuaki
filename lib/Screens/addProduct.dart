import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giuaki/service/productService.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController      = TextEditingController();
  final TextEditingController priceController     = TextEditingController();
  final TextEditingController categoryController  = TextEditingController();
  final productService        _productService     = productService();

  File? _image;

  Future<void> _pickImage() async {
    final picker      = ImagePicker();
    final pickedFile  = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile    != null) {
      setState(() {
        _image        = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    try {
      await _productService.addProduct(
        name      : nameController.text.trim(),
        price     : priceController.text.trim(),
        category  : categoryController.text.trim(),
        image     : _image,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm sản phẩm thành công')),
      );

      nameController    .clear();
      priceController   .clear();
      categoryController.clear();
      setState(() {
        _image = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Tên sản phẩm',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: 'Loại sản phẩm',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Giá sản phẩm',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _image != null
                  ? Image.file(_image!, width: 100, height: 100, fit: BoxFit.cover)
                  : Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Chọn ảnh'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Center(
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Thêm sản phẩm'),
            ),
          ),
        ],
      ),
    );
  }
}
