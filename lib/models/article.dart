class Article {
  final int id;
  final String title;
  final String content;
  final String language;
  final String? image;
  final int author;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.language,
    this.image,
    required this.author,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      language: json['language'] as String,
      image: json['image'] as String?,
      author: json['author'] as int,
      authorName: json['author_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'language': language,
      'image': image,
      'author': author,
      'author_name': authorName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

