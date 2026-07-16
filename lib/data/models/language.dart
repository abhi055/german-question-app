class Language {
  final String image, text;

  Language({required this.image, required this.text});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(image: json['image'], text: json['text']);
  }
}
