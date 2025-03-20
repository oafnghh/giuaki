import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
class ImgBB {
   final String clientId = '788790fd0044f42'; 
  Future<String?> uploadToImgur(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://api.imgur.com/3/image"),
      );
      request.headers["Authorization"] = "Client-ID $clientId";
      request.files.add(await http.MultipartFile.fromPath("image", image.path));

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(responseData.body);
        return jsonData["data"]["link"];
      } else {
        print("Lỗi upload ảnh: ${responseData.body}");
        return null;
      }
    } on SocketException catch (e) {
      print("⚠ Lỗi mạng: Không thể kết nối đến Imgur. Kiểm tra mạng và thử lại.");
      return null;
    } on HttpException catch (e) {
      print("⚠ Lỗi HTTP: $e");
      return null;
    } on FormatException catch (e) {
      print("⚠ Lỗi format dữ liệu: $e");
      return null;
    } on Exception catch (e) {
      print("⚠ Lỗi không xác định: $e");
      return null;
    }
  }
}
