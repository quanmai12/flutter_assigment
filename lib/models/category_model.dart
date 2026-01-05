class Category {
  final int id;
  final String name;
  final String slug;

  Category({required this.id, required this.name, required this.slug});

  // Hàm chuyển từ JSON sang Object Dart
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? 'No Name',
      slug: json['slug'] ?? '',
    );
  }
}