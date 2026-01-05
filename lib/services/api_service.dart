import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../models/category_model.dart';

class ApiService {
  // --- CẤU HÌNH IP ---
  // Lưu ý: Thay đổi IP này tùy theo môi trường (Emulator: 10.0.2.2, Máy thật: IP Wifi)
  // Nếu dùng máy thật qua USB (adb reverse): dùng 127.0.0.1 hoặc localhost
  static const String baseUrl = "http://127.0.0.1:1337/api";

  // Hàm lấy danh sách sự kiện (Có hỗ trợ Phân trang & Lọc)
  Future<List<Event>> getEvents({int page = 1, int pageSize = 10, int? categoryId}) async {
    // Xây dựng URL truy vấn
    // populate=*: Để lấy cả thông tin Category và ảnh
    // sort=date:desc: Sắp xếp sự kiện mới nhất lên đầu
    String url = '$baseUrl/events?populate=*&sort=date:desc&pagination[page]=$page&pagination[pageSize]=$pageSize';

    // Nếu có chọn danh mục, thêm điều kiện lọc
    if (categoryId != null && categoryId != 0) {
      url += '&filters[category][id][\$eq]=$categoryId';
    }

    print("Requesting: $url"); // In ra để debug xem URL đúng không

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];

        // Chuyển đổi từ List JSON sang List<Event>
        return data.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print("Error fetching events: $e");
      // Trả về danh sách rỗng nếu lỗi để App không bị crash
      return [];
    }
  }

  // Hàm lấy danh sách danh mục (Cho chức năng lọc sau này)
  Future<List<Category>> getCategories() async {
    final String url = '$baseUrl/categories';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      return [];
    }
  }
}