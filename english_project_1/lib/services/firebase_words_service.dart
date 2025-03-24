
import 'package:cloud_firestore/cloud_firestore.dart';

class Word {
  final int id;
  final int categoryId;
  final String eng;
  final String tr;

  Word({required this.id, required this.categoryId, required this.eng, required this.tr});

  factory Word.fromFirestore(Map<String, dynamic> data) {
    return Word(
      id: data['id'] ?? 0,
      categoryId: data['categoryId'] ?? 1,
      eng: data['eng'] ?? 'Unknown',
      tr: data['tr'] ?? 'Bilinmiyor',
    );
  }
}

abstract class IWordService {
  Future<List<Word>> fetchWords();
}

class FirebaseWordService implements IWordService {
  final FirebaseFirestore _firestore;

  // Singleton deseniyle tek bir instance kullanımı (isteğe bağlı DI ile de kullanılabilir)
  FirebaseWordService(this._firestore);

  @override
  Future<List<Word>> fetchWords() async {
    try {
      final querySnapshot = await _firestore.collection('words').get();
      final words = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Word.fromFirestore(data);
      }).toList();
      return words;
    } catch (e) {
      print('Firebase’den kelimeler çekilirken hata: $e');
      return [];
    }
  }
}
