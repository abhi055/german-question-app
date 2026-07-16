import 'package:question_app/database/sqldb.dart';

class SavedDbData {
  Sqldb db = Sqldb();

  // Get all saved questions
  Future<List<int>> getAllSavedQuestions() async {
    List<Map<String, dynamic>> response = await db.readData(
      "SELECT * FROM saved_questions ORDER BY question_index ASC",
    );

    return response.map((e) => e['question_index'] as int).toList();
  }

  // Insert or Update index
  Future<int> upsertIndex({required int index}) async {
    int response = await db.insertData(
      "INSERT OR REPLACE INTO saved_questions(question_index) VALUES($index)",
    );

    return response;
  }

  // Delete index data
  Future<int> deleteIndex({required int index}) async {
    int response = await db.deleteData(
      "DELETE FROM saved_questions WHERE question_index=$index",
    );

    return response;
  }

  // Get all analysed questions
  Future<List<Map<String, dynamic>>> getAllAnalysedQuestions() async {
    List<Map<String, dynamic>> response = await db.readData(
      "SELECT * FROM analysed_questions ORDER BY question_index ASC",
    );
    return response;
  }

  // Get specific analysed question
  Future<Map<String, dynamic>> getSpecificAnalysedQuestion(
    int questionIndex,
  ) async {
    List<Map<String, dynamic>> response = await db.readData(
      "SELECT * FROM analysed_questions WHERE question_index=$questionIndex",
    );

    // Return first item if found, otherwise null
    return response.isNotEmpty
        ? response.first
        : {
            'question_index': questionIndex,
            'correct_count': 0,
            'incorrect_count': 0,
          };
  }

  // Insert or Update analysed question
  Future<int> upsertAnalysedQuestion({
    required int index,
    required bool isTrue,
  }) async {
    Map<String, dynamic> existingData = await getSpecificAnalysedQuestion(
      index,
    );

    int newCorrectCount = existingData['correct_count'] ?? 0;
    int newIncorrectCount = existingData['incorrect_count'] ?? 0;

    if (isTrue) {
      newCorrectCount++;
    } else {
      newIncorrectCount++;
    }

    int response = await db.insertData('''
    INSERT OR REPLACE INTO analysed_questions (question_index, correct_count, incorrect_count)
    VALUES ($index, $newCorrectCount, $newIncorrectCount)
    ''');

    return response;
  }

  // Get previous test results
  Future<List<Map<String, dynamic>>> getAllTestResults() async {
    List<Map<String, dynamic>> response = await db.readData(
      "SELECT * FROM test_results ORDER BY test_index ASC",
    );

    // Return first item if found, otherwise null
    return response;
  }

  // Get previous test result
  Future<Map<String, dynamic>> getTestResult(int index) async {
    List<Map<String, dynamic>> response = await db.readData(
      "SELECT * FROM test_results WHERE test_index = $index",
    );

    // Return first item if found, otherwise null
    return response.isNotEmpty
        ? response.first
        : {'index': 0, 'correct_count': 0, 'incorrect_count': 0};
  }

  // Insert test result
  Future<int> insertTestResult({
    required int correctCount,
    required int incorrectCount,
  }) async {
    int response = await db.insertData('''
    INSERT INTO test_results (correct_count, incorrect_count)
    VALUES ($correctCount, $incorrectCount)
    ''');

    return response;
  }

  // Delete all data inside tables
  Future<void> deleteAllData() async {
    final tables = ["saved_questions", "analysed_questions", "test_results"];

    for (final table in tables) {
      await db.deleteData("DELETE FROM $table");
    }
  }

  // Delete database
  Future<void> deleteDatabase() async => await db.deleteMyDb();
}
