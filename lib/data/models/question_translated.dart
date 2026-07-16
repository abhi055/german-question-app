class QuestionTranslated {
  final String question;
  final List<dynamic> options;
  final String correctAnswer;
  final String category;
  final String? state;
  QuestionTranslated({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category,
    this.state,
  });

  factory QuestionTranslated.fromJson(Map<String, dynamic> json) {
    return QuestionTranslated(
      question: json['question']?.toString().trim() ?? '',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .toList() ??
          [],
      correctAnswer: json['correctAnswer']?.toString().trim() ?? '',
      category: json['category']?.toString() ?? '',
      state: json['state']?.toString(),
    );
  }

  @override
  String toString() {
    return 'Question{question: $question, correctAnswer: $correctAnswer, category: $category}';
  }
}
