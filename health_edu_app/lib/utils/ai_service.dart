import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AIService {
  static Future<String> analyzePeriod(int durationDays, List<String> symptoms) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('OpenAI API Key is missing. Falling back to static message.');
      return _getStaticFallbackMessage(durationDays);
    }

    final symptomsText = symptoms.isEmpty ? 'tidak ada gejala tercatat' : symptoms.join(', ');

    final prompt = 'Pengguna baru saja selesai haid dengan durasi $durationDays hari, dengan gejala: $symptomsText.';

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'Kamu adalah asisten kesehatan reproduksi remaja yang ramah bernama BloomFem AI. '
                  'Berikan analisis medis ringan, menenangkan, maksimal 3 kalimat pendek. '
                  'Jangan berikan diagnosis berat, sarankan ke dokter jika durasi <2 hari atau >8 hari.'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 150,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String?;
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
      } else {
        debugPrint('OpenAI API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Failed to fetch AI analysis: $e');
    }

    return _getStaticFallbackMessage(durationDays);
  }

  static String _getStaticFallbackMessage(int durationDays) {
    if (durationDays < 2 || durationDays > 8) {
      return 'Durasi haidmu kali ini adalah $durationDays hari. ⚠️ Durasi di bawah 2 hari atau di atas 8 hari bisa menjadi tanda ketidakseimbangan hormon atau hal lain pada remaja. Disarankan untuk berkonsultasi dengan dokter untuk memastikan kesehatanmu ya, Bloom! 🌸';
    }
    return 'Durasi haidmu kali ini adalah $durationDays hari. 💡 Info Medis: Siklus haid normal bagi remaja biasanya berlangsung selama 3 hingga 7 hari. Durasi haidmu kali ini berada dalam batas normal. Jaga kesehatan reproduksimu selalu ya! 🌸';
  }
}
