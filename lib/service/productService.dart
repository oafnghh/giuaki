import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giuaki/API/ImgBB.dart';
class productService{

  final CollectionReference docRef =FirebaseFirestore.instance.collection("products");
  final ImgBB _imgBB = ImgBB();

  
  Future<void> deleteProduct(String id) async {
    await docRef.doc(id).delete();
  }

  // Stream<QuerySnapshot> getProducts() {
  //   return docRef.snapshots();
  // }

  Stream<List<QueryDocumentSnapshot>> getFilteredProducts(String searchQuery) {
    return docRef.snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        var product = doc.data() as Map<String, dynamic>;
        String productName = (product["name"] ?? "").toLowerCase();
        return productName.contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  Future<void> addProduct({
    required String name,
    required String price,
    required String category,
    File? image,
  }) async {
    if (name.isEmpty || price.isEmpty || category.isEmpty) {
      throw Exception("Vui lòng nhập đầy đủ thông tin");
    }

    String? imageUrl;
    if (image != null) {
      imageUrl = await _imgBB.uploadToImgur(image);
      if (imageUrl == null) {
        throw Exception("Lỗi tải ảnh lên ImgBB");
      }
    }

    await docRef.add({
      'name': name,
      'price': price,
      'category': category,
      'imageUrl': imageUrl ?? '',
    });
  }

  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc =
          await docRef.doc(productId).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception("Lỗi khi lấy dữ liệu sản phẩm: $e");
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
  try {
    await docRef.doc(productId).update(data);
  } catch (e) {
    throw Exception("Lỗi khi cập nhật sản phẩm: $e");
  }
}

}