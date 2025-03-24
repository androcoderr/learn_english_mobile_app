import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';

abstract class IQuizService {
  Future<List<QuizQuestion>> fetchQuizQuestions();
}

class QuizService implements IQuizService {
  final String ollamaApiUrl = "http://localhost:11434/api/generate"; // Ollama'nın varsayılan API URL'si
  final String modelName = "gemma"; // Kullanacağın model (gemma, codellama vs.)

  @override
  Future<List<QuizQuestion>> fetchQuizQuestions() async {
    try {
      final response = await http.post(
        Uri.parse(ollamaApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "model": modelName,
          "prompt": "Generate a multiple-choice quiz with 4 options (A, B, C, D). Return JSON format with question, options, and correct answer."
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Ollama çıktısı genellikle `response['response']` içinde olur, onu JSON'a çevirelim
        final List<dynamic> quizData = jsonDecode(responseData['response']);

        return quizData.map((json) => QuizQuestion.fromJson(json)).toList();
      } else {
        throw Exception("Ollama API hatası: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Quiz soruları alınırken hata: $e");
    }
  }
}