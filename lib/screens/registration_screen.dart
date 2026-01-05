import 'package:flutter/material.dart';
import 'dart:convert'; // Để xử lý JSON
import 'package:http/http.dart' as http; // Thư viện gửi yêu cầu mạng
import '../models/event_model.dart';


class RegistrationPage extends StatefulWidget {
  final Event event;
  //Nhận dữ liệu sự kiện
  const RegistrationPage({super.key, required this.event});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Key để quản lý trạng thái của Form và Validate
  final _formKey = GlobalKey<FormState>();

  // Controller để lấy dữ liệu từ các ô nhập
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {

      // --- CẤU HÌNH CHO KẾT NỐI USB (ADB REVERSE) ---
      // Khi đã chạy "adb reverse tcp:1337 tcp:1337",
      // điện thoại hiểu localhost chính là máy tính của bạn.
      const String strapiUrl = "http://127.0.0.1:1337/api/registrations";
      // Hoặc dùng: "http://localhost:1337/api/registrations";
      // ---------------------------------------------

      final name = _nameController.text;
      final email = _emailController.text;
      final phone = _phoneController.text;


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang gửi yêu cầu đăng kí...')),
      );

      try {
        final response = await http.post(
          Uri.parse(strapiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'data': {
              'name': name,
              'email': email,
              'phone': phone,
              'event' : widget.event.id,
            }
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // ... Code xử lý thành công ...
          print("Thành công!");
          if (!mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Thành công"),
              content: Text("Bạn đã đăng ký tham gia sự kiện:\n${widget.event.title}"),
              actions: [
                TextButton(onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);// Quay về trang chủ
                },
                    child: const Text("OK"),
                ),
              ],
            ),
          );
        } else {
          throw Exception("Lỗi: ${response.statusCode}");
        }

      } catch (e) {
        print("Lỗi kết nối: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
              content: Text('Lỗi kết nối: $e.\nHãy chắc chắn bạn đã chạy lệnh "adb reverse tcp:1337 tcp:1337"'),
              backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ controller khi thoát màn hình
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = "${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}";
    final timeStr = "${widget.event.date.hour}:${widget.event.date.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết sự kiện"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PHẦN 1: ẢNH BÌA LỚN ---
            SizedBox(
              height: 220, // Chiều cao cố định cho ảnh bìa
              width: double.infinity,
              child: Image.network(
                widget.event.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                ),
              ),
            ),

            // --- PHẦN 2: THÔNG TIN CHI TIẾT ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Category
                  if (widget.event.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.event.category!.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Tiêu đề lớn
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Dòng thời gian
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        "$dateStr lúc $timeStr",
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(), // Đường kẻ ngang
                  const SizedBox(height: 16),

                  // Tiêu đề Mô tả
                  const Text(
                    "Mô tả sự kiện",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Nội dung mô tả (Cho phép hiển thị dài)
                  Text(
                    widget.event.description ?? "Chưa có mô tả chi tiết cho sự kiện này.",
                    style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
                  ),
                ],
              ),
            ),

            // --- PHẦN 3: FORM ĐĂNG KÝ (Được bọc trong Card cho nổi bật) ---
            Container(
              color: Colors.grey[50], // Nền xám nhẹ để tách biệt
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        "ĐĂNG KÝ THAM GIA",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input: Họ tên
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Họ và tên",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) => v!.isEmpty ? "Vui lòng nhập tên" : null,
                    ),
                    const SizedBox(height: 16),

                    // Input: Email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) => v!.contains("@") ? null : "Email không hợp lệ",
                    ),
                    const SizedBox(height: 16),

                    // Input: Số điện thoại
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Số điện thoại",
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) => v!.length >= 10 ? null : "SĐT phải từ 10 số",
                    ),
                    const SizedBox(height: 30),

                    // Nút Submit
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.send),
                        label: const Text("XÁC NHẬN ĐĂNG KÝ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Khoảng trống dưới cùng
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}