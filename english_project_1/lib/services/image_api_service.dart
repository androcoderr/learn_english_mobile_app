
// image_api_service.dart
class ImageApiService {
  final String baseUrl; // Örneğin: "http://localhost:5000"

  ImageApiService({required this.baseUrl});

  // Kelimeye göre resim URL'sini oluşturur.
  String getImageUrl(String word) {
    return "$baseUrl/image/${word.toLowerCase()}.png";
  }
}
