import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    if (password != confirmPassword) {
      _showMessage(context, "Mật khẩu không khớp!");
      return;
    }

    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        _showMessage(context, "Đăng ký thành công! Vui lòng kiểm tra email để xác thực.");
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(context, "Lỗi: ${e.code} - ${e.message}");
      print("Lỗi Firebase: ${e.code} - ${e.message}");
    } catch (e) {
      _showMessage(context, "Lỗi không xác định: $e");
      print("Lỗi không xác định: $e");
    }
  }


  Future<String?> login({required String email, required String password}) async {
  try {
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final User? user = userCredential.user;
    if (user != null) {
      if (!user.emailVerified) {
        return "Email chưa được xác thực. Vui lòng kiểm tra hộp thư.";
      }
      return "Đăng nhập thành công";
    }
    
  } on FirebaseAuthException catch (e) {
    return _getFirebaseAuthErrorMessage(e.code);
  } catch (e) {
    return "Lỗi không xác định: $e";
  }
  return null;
}

String _getFirebaseAuthErrorMessage(String code) {
  switch (code) {
    case 'user-not-found':
      return 'Tài khoản không tồn tại.';
    case 'wrong-password':
      return 'Mật khẩu không đúng.';
    case 'invalid-email':
      return 'Email không hợp lệ.';
    case 'user-disabled':
      return 'Tài khoản này đã bị vô hiệu hóa.';
    case 'too-many-requests':
      return 'Bạn đã nhập sai quá nhiều lần. Hãy thử lại sau.';
    case 'operation-not-allowed':
      return 'Chức năng đăng nhập bằng email chưa được bật.';
    default:
      return 'Lỗi không xác định. Vui lòng thử lại.';
  }
}


  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
