import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../models/karar.dart';
import '../utils/theme.dart';

class ViralExportService {
  static final ViralExportService _instance = ViralExportService._internal();
  factory ViralExportService() => _instance;
  ViralExportService._internal();

  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> shareAsStory({
    required BuildContext context,
    required Karar karar,
  }) async {
    final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
      _buildStoryCard(karar),
      pixelRatio: 3.0,
    );

    if (imageBytes != null) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/hakli_kim_story.png');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '⚖️ ${karar.hakliKisi} haklı! Jüri: ${karar.juriTipi}',
      );
    }
  }

  Future<void> shareAsMeme({
    required BuildContext context,
    required Karar karar,
  }) async {
    final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
      _buildMemeCard(karar),
      pixelRatio: 3.0,
    );

    if (imageBytes != null) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/hakli_kim_meme.png');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${karar.hakliKisi} haklı mı? 😲',
      );
    }
  }

  Future<void> shareAsWhatsAppStatus({
    required BuildContext context,
    required Karar karar,
  }) async {
    final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
      _buildWhatsAppStatusCard(karar),
      pixelRatio: 3.0,
    );

    if (imageBytes != null) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/hakli_kim_status.png');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '📱 WhatsApp Status için kaydet!',
      );
    }
  }

  Widget _buildStoryCard(Karar karar) {
    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
            AppTheme.accentColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚖️', style: TextStyle(fontSize: 120)),
            const SizedBox(height: 40),
            Text(
              'KİM HAKLI?',
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 80),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                karar.hakliKisi,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Haksızlık Oranı: %${karar.haksizlikOrani}',
              style: const TextStyle(
                fontSize: 40,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 60),
            Text(
              karar.juriTipi,
              style: const TextStyle(
                fontSize: 35,
                color: Colors.white54,
              ),
            ),
            const Spacer(),
            Text(
              'Haklı Kim? - AI ile Analiz',
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemeCard(Karar karar) {
    return Container(
      width: 720,
      height: 720,
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚖️', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(
              'MAHKEME KARARI',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                karar.hakliKisi,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Haksızlık: %${karar.haksizlikOrani}',
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              karar.ceza,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppStatusCard(Karar karar) {
    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade800,
            Colors.green.shade600,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.gavel, size: 100, color: Colors.white),
            const SizedBox(height: 30),
            const Text(
              'WHATSAPP STATUS',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 50),
            Text(
              karar.hakliKisi,
              style: const TextStyle(
                fontSize: 70,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'HAKLI!',
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '%${karar.haksizlikOrani} haksız bulundu',
              style: const TextStyle(
                fontSize: 30,
                color: Colors.white70,
              ),
            ),
            const Spacer(),
            const Text(
              'Haklı Kim? uygulamasından',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}