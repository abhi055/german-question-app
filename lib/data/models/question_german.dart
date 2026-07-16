class QuestionGerman {
  final String question;
  final List<dynamic> options;
  final String correctAnswer;
  final int index;
  final String? state;
  final String category;

  QuestionGerman({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.index,
    required this.category,
    this.state,
  });

  factory QuestionGerman.fromJson(Map<String, dynamic> json, int index) {
    // Handle both "correctAnswer" and "correct_answer" field names
    String correctAnswer =
        json['correctAnswer']?.toString().trim() ??
        json['correct_answer']?.toString().trim() ??
        '';

    // Ensure options is a List<String>
    List<String> options = [];
    if (json['options'] != null) {
      options = (json['options'] as List<dynamic>)
          .map((e) => e.toString().trim())
          .toList();
    }

    String? state;
    if (json['state'] != null) {
      state = json['state']?.toString().trim();
    }

    return QuestionGerman(
      index: index,
      question: json['question']?.toString().trim() ?? '',
      options: options,
      correctAnswer: correctAnswer,
      category: json['category'].toString().trim(),
      state: state,
    );
  }

  @override
  String toString() {
    return 'QuestionGerman{index: $index, question: $question, correctAnswer: $correctAnswer, category: $category}';
  }
}
