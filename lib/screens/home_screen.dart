import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../screens/registration_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  // Dữ liệu Sự kiện
  List<Event> _events = []; // Danh sách sự kiện hiển thị
  bool _isLoadingEvents = false;  // Trạng thái đang tải
  bool _hasMore = true;     // Còn dữ liệu để tải không?
  int _page = 1;            // Trang hiện tại
  final int _pageSize = 4; // Số lượng tải mỗi lần

  // Dữ liệu Danh mục
  List<Category> _categories = [];
  int _selectedCategoryId = 0; // 0 nghĩa là chọn "Tất cả"
  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Tải danh mục trước
    _fetchEvents(); // Tải dữ liệu lần đầu

    // Lắng nghe sự kiện cuộn
    _scrollController.addListener(() {
      // Nếu cuộn xuống tận cùng và không đang tải và còn dữ liệu
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          !_isLoadingEvents &&
          _hasMore) {
        _fetchEvents(); // Tải trang tiếp theo
      }
    });
  }
  // Hàm tải danh mục
  Future<void> _fetchCategories() async {
    final cats = await _apiService.getCategories();
    if (mounted) {
      setState(() {
        // Thêm mục "Tất cả" vào đầu danh sách
        _categories = [Category(id: 0, name: "Tất cả", slug: "all"), ...cats];
      });
    }
  }

  // Hàm tải dữ liệu
  Future<void> _fetchEvents() async {
    if (_isLoadingEvents) return;

    setState(() {
      _isLoadingEvents = true;
    });

    // Gọi API
    final newEvents = await _apiService.getEvents(
        page: _page,
        pageSize: _pageSize,
        categoryId: _selectedCategoryId == 0 ? null : _selectedCategoryId
    );

    if (mounted){
      setState(() {
        _isLoadingEvents = false;
        if (newEvents.length < _pageSize) {
          // Nếu số lượng trả về ít hơn pageSize -> Đã hết dữ liệu
          _hasMore = false;
        }

        _events.addAll(newEvents); // Nối dữ liệu mới vào danh sách cũ
        _page++; // Tăng số trang cho lần tải sau
      });
    }
  }

  // Hàm xử lý khi chọn danh mục
  void _onCategorySelected(int categoryId) {
    if (_selectedCategoryId == categoryId) return; // Chọn lại cái cũ thì thôi

    setState(() {
      _selectedCategoryId = categoryId;
      _events.clear(); // Xóa sạch list cũ
      _page = 1;       // Reset về trang 1
      _hasMore = true; // Reset trạng thái load
    });
    _fetchEvents(); // Gọi API tải lại theo danh mục mới
  }

  // Hàm làm mới (Kéo từ trên xuống)
  Future<void> _refresh() async {
    setState(() {
      _events.clear();
      _page = 1;
      _hasMore = true;
    });
    await _fetchEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tech Events"),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
      ),
      body: Column(
        children: [
          // --- PHẦN 1: THANH CATEGORY (MỚI) ---
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Cuộn ngang
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat.id == _selectedCategoryId;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) _onCategorySelected(cat.id);
                    },
                    selectedColor: Theme
                        .of(context)
                        .colorScheme
                        .primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected ? Theme
                          .of(context)
                          .colorScheme
                          .primary : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight
                          .normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // --- PHẦN 2: DANH SÁCH SỰ KIỆN ---
          Expanded( // Chiếm hết phần còn lại
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _events.isEmpty
                  ? Center(child: _isLoadingEvents
                  ? const CircularProgressIndicator()
                  : const Text("Không tìm thấy sự kiện nào!"))
                  : ListView.builder(
                controller: _scrollController,
                itemCount: _events.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _events.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final event = _events[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 150, width: double.infinity,
                          child: Image.network(
                              event.imageUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.error)),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tên Category (Nếu có)
                                if (event.category != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      event.category!.name,
                                      style: TextStyle(fontSize: 11, color: Colors.blue[800], fontWeight: FontWeight.bold),
                                    ),
                                  ),

                                // Tiêu đề
                                Text(
                                  event.title,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),

                                // --- MỚI: MÔ TẢ (DESCRIPTION) ---
                                const SizedBox(height: 6),
                                if (event.description != null && event.description!.isNotEmpty)
                                  Text(
                                    event.description!,
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                    maxLines: 2, // Giới hạn 2 dòng
                                    overflow: TextOverflow.ellipsis, // Dài quá hiện dấu ...
                                  ),
                                // -------------------------------

                                // Ngày tháng
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${event.date.day}/${event.date.month}/${event.date.year}",
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Nút Đăng ký
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(

                                          builder: (context) => RegistrationPage(event: event),
                                        ),
                                      );
                                    },
                                    child: const Text("Chi tiết & Đăng ký"),
                                  ),
                                )
                              ],
                            ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}