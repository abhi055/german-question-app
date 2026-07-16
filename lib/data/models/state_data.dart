class StateData {
  final String text, image;

  StateData({required this.text, required this.image});

  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(text: json['text'], image: json['image']);
  }
}
