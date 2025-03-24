
import 'package:flutter/material.dart';

import '../models/quiz.dart';
import '../services/quiz_service.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const QuizPage(),
    );
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final IQuizService quizService = QuizService();
  List<QuizQuestion> _quizQuestions = [];
  int _currentQuestionIndex = 0;
  int _selectedOption = -1;
  int _score = 0;
  bool _answered = false;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadQuizQuestions();
  }

  Future<void> _loadQuizQuestions() async {
    try {
      final questions = await quizService.fetchQuizQuestions();
      setState(() {
        _quizQuestions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _checkAnswer(int selectedIndex) {
    if (_answered) return;

    setState(() {
      _selectedOption = selectedIndex;
      _answered = true;
      // Diyelim ki answer "B" ise, index 1’i kontrol ediyoruz
      if (String.fromCharCode(65 + selectedIndex) == _quizQuestions[_currentQuestionIndex].answer) {
        _score += 10;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = -1;
        _answered = false;
      });
    } else {
      // Quiz tamamlandı, sonucu göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            'Quiz Tamamlandı',
            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _score >= (_quizQuestions.length * 10 * 0.7) ? Icons.emoji_events : Icons.school,
                color: Colors.blue.shade700,
                size: 60,
              ),
              const SizedBox(height: 10),
              Text(
                'Puanınız: $_score / ${_quizQuestions.length * 10}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _score >= (_quizQuestions.length * 10 * 0.7)
                    ? 'Tebrikler! Harika bir sonuç.'
                    : 'Daha fazla çalışmaya devam et!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _currentQuestionIndex = 0;
                    _selectedOption = -1;
                    _answered = false;
                    _score = 0;
                  });
                },
                child: const Text('Yeniden Başla', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Yükleniyor ekranı
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text('Sorular yükleniyor...', style: TextStyle(color: Colors.blue.shade700, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    // Hata durumunda
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hata: $_errorMessage', style: TextStyle(color: Colors.red.shade700, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadQuizQuestions,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    // Ana Quiz Ekranı
    final currentQuiz = _quizQuestions[_currentQuestionIndex];
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst Kısım: Soru numarası ve Puan
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade900.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: SweepGradient(colors: [Colors.white, Colors.blue]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Soru ${_currentQuestionIndex + 1}/${_quizQuestions.length}',
                        style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Puan: $_score',
                        style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Soru ve Şıklar
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Soru Kutusu
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade50, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "SORU ${_currentQuestionIndex + 1}",
                              style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentQuiz.question,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Şıklar
                      Expanded(
                        child: ListView.builder(
                          itemCount: currentQuiz.options.length,
                          itemBuilder: (context, index) {
                            final isCorrect = String.fromCharCode(65 + index) == currentQuiz.answer;
                            final isSelected = _selectedOption == index;

                            // Renk ayarlamaları
                            Color backgroundColor = Colors.white;
                            Color textColor = Colors.blue.shade700;
                            Color borderColor = Colors.blue.shade300;

                            if (_answered) {
                              if (isCorrect) {
                                backgroundColor = Colors.green.shade100;
                                borderColor = Colors.green;
                                textColor = Colors.green.shade800;
                              } else if (isSelected) {
                                backgroundColor = Colors.red.shade100;
                                borderColor = Colors.red;
                                textColor = Colors.red.shade800;
                              }
                            } else if (isSelected) {
                              backgroundColor = Colors.blue.shade700;
                              textColor = Colors.white;
                              borderColor = Colors.blue.shade700;
                            }

                            return GestureDetector(
                              onTap: () => _checkAnswer(index),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  gradient: LinearGradient(
                                    colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(color: borderColor, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.shade100.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white : Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: borderColor, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          String.fromCharCode(65 + index),
                                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        currentQuiz.options[index],
                                        style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    if (_answered && isCorrect)
                                      Icon(Icons.check_circle, color: Colors.green.shade700),
                                    if (_answered && isSelected && !isCorrect)
                                      Icon(Icons.cancel, color: Colors.red.shade700),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // İlerleme Butonu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _answered ? Colors.blue.shade700 : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    shadowColor: Colors.blue.shade900,
                  ),
                  onPressed: _answered ? _nextQuestion : null,
                  child: Text(
                    _currentQuestionIndex < _quizQuestions.length - 1 ? 'Sonraki Soru' : 'Sonuçları Gör',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
