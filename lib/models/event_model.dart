import 'category_model.dart';

class Event {
  final int id;
  final String title;
  final String? description; // Có thể null
  final DateTime date;
  final String imageUrl;
  final Category? category; // Có thể null nếu event chưa chọn danh mục

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.imageUrl,
    this.category,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      description: json['description'],
      // Chuyển chuỗi ngày giờ ISO 8601 sang DateTime
      date: DateTime.parse(json['date']),
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      // Nếu có category thì map, không thì null
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
    );
  }
}