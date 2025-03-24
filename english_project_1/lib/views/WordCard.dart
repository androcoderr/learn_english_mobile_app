import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/firebase_words_service.dart';
import '../services/image_api_service.dart'; // Yeni servis import

// FlipCard widget'ı (değişiklikler _buildCardFace fonksiyonunda)
class FlipCard extends StatefulWidget {
  final String englishWord;
  final String turkishWord;
  final int categoryId;

  const FlipCard({
    Key? key,
    required this.englishWord,
    required this.turkishWord,
    required this.categoryId,
  }) : super(key: key);

  @override
  _FlipCardState createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _frontAnimation;
  late Animation<double> _backAnimation;
  bool isFlipped = false;

  // Image API servisini tanımlıyoruz (URL'yi kendi sunucuna göre güncelle)
  final ImageApiService _imageApiService = ImageApiService(baseUrl: "http://localhost:5000");

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _frontAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: math.pi / 2).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(math.pi / 2),
        weight: 50.0,
      ),
    ]).animate(_controller);

    _backAnimation = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween<double>(math.pi / 2),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: math.pi / 2, end: math.pi).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
    ]).animate(_controller);
  }

  void _toggleCard() {
    setState(() {
      if (isFlipped) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
      isFlipped = !isFlipped;
    });
  }

  Color _getCardColor() {
    switch (widget.categoryId) {
      case 1:
        return Colors.blue.shade700;
      case 2:
        return Colors.green.shade700;
      case 3:
        return Colors.orange.shade700;
      case 4:
        return Colors.purple.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          children: [
            // Ön yüz (İngilizce kelime)
            AnimatedBuilder(
              animation: _frontAnimation,
              builder: (context, child) {
                final transform = Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(_frontAnimation.value);
                if (_frontAnimation.value > math.pi / 2) {
                  transform..rotateY(math.pi);
                }
                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: _frontAnimation.value >= math.pi / 2
                      ? Container()
                      : _buildCardFace(widget.englishWord, _getCardColor()),
                );
              },
            ),
            // Arka yüz (Türkçe kelime)
            AnimatedBuilder(
              animation: _backAnimation,
              builder: (context, child) {
                final transform = Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(_backAnimation.value);
                if (_backAnimation.value > math.pi / 2) {
                  transform..rotateY(math.pi);
                }
                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: _backAnimation.value <= math.pi / 2
                      ? Container()
                      : _buildCardFace(widget.turkishWord, Colors.teal.shade700),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // _buildCardFace fonksiyonunu resim ve metin gösterecek şekilde güncelledik
  Widget _buildCardFace(String text, Color color) {
    // API servisinden resim URL'sini alıyoruz
    final imageUrl = _imageApiService.getImageUrl(text);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Resim kısmı
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image, size: 80, color: Colors.white);
                  },
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Metin kısmı (Kelime)
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
