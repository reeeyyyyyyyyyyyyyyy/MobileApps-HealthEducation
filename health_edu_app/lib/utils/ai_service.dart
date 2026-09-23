import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AIService {
  /// Analyze risk check result and provide personalized recommendation
  static Future<String> analyzeRiskResult(int totalScore, int maxScore, String riskLevel) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return _getStaticRiskMessage(riskLevel);
    }

    final prompt = 'Pengguna remaja putri baru saja melakukan check risiko ISK. '
        'Skor: $totalScore dari $maxScore. Level risiko: $riskLevel. '
        'Berikan rekomendasi personal 3-4 kalimat.';

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
              'content': 'Kamu adalah Suster Care, asisten kesehatan ISK (Infeksi Saluran Kemih) '
                  'untuk remaja putri. Berikan rekomendasi medis ringan, menenangkan, dan edukatif. '
                  'Maksimal 4 kalimat pendek. Jangan diagnosis berat.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 200,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String?;
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
      }
    } catch (e) {
      debugPrint('AI risk analysis error: $e');
    }

    return _getStaticRiskMessage(riskLevel);
  }

  static String _getStaticRiskMessage(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'rendah':
        return 'Hasil menunjukkan risiko ISK kamu rendah. Kamu sudah menjaga '
            'kebiasaan sehat dengan baik! Tetap pertahankan pola minum air '
            'yang cukup dan kebersihan area genital.';
      case 'sedang':
        return 'Risiko ISK kamu berada di level sedang. Perhatikan konsumsi air putihmu '
            'dan hindari menahan BAK terlalu lama. Tingkatkan kebersihan area genital '
            'dengan cara membersihkan dari depan ke belakang.';
      case 'tinggi':
        return 'Risiko ISK kamu cukup tinggi. Segera perbaiki kebiasaan harianmu: '
            'minum minimal 8 gelas air per hari, jangan menahan BAK, dan jaga '
            'kebersihan area genital. Disarankan konsultasi ke tenaga kesehatan.';
      default:
        return 'Terus pantau kesehatanmu dan lakukan check risk secara berkala.';
    }
  }

  /// Generate daily tip about ISK prevention
  static Future<String> generateDailyTip() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return 'Minum air putih minimal 8 gelas per hari untuk menjaga kesehatan saluran kemihmu.';
    }

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
              'content': 'Generate 1 tips kesehatan harian tentang pencegahan ISK untuk remaja putri. '
                  'Singkat, 1-2 kalimat, mudah dipahami, bernada positif.'
            },
            {'role': 'user', 'content': 'Berikan 1 tips pencegahan ISK hari ini.'}
          ],
          'temperature': 0.9,
          'max_tokens': 100,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String?;
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
      }
    } catch (e) {
      debugPrint('AI daily tip error: $e');
    }

    return 'Jangan menahan keinginan buang air kecil terlalu lama. '
        'Kebiasaan ini dapat meningkatkan risiko bakteri berkembang di saluran kemih.';
  }

  /// Chat with AI as "Suster Care" - ISK health assistant
  static Future<String> chatWithAI(List<Map<String, String>> chatHistory) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return 'Maaf, aku lagi tidak bisa terhubung ke server. Pastikan koneksi internetmu baik.';
    }

    String userContext = '';
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null) {
          final name = profile['full_name'] ?? 'Pengguna';
          userContext += '\n\nINFORMASI PENGGUNA:';
          userContext += '\n- Nama: $name';
          userContext += '\n- Usia: ${profile['age'] ?? 'tidak diketahui'} tahun';
          userContext += '\n- Sekolah: ${profile['school'] ?? 'tidak diketahui'}';
        }

        // Get latest risk result
        final risk = await Supabase.instance.client
            .from('risk_results')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (risk != null) {
          userContext += '\n- Risiko ISK terakhir: ${risk['risk_level']} (skor ${risk['total_score']})';
        }

        // Get today's habits
        final today = DateTime.now().toIso8601String().substring(0, 10);
        final habits = await Supabase.instance.client
            .from('daily_habits')
            .select()
            .eq('user_id', user.id)
            .eq('log_date', today)
            .maybeSingle();

        if (habits != null) {
          userContext += '\n- Minum air hari ini: ${habits['water_intake']} gelas';
          userContext += '\n- Aktivitas fisik: ${habits['physical_activity']} menit';
        }
      }
    } catch (_) {}

    final systemPrompt = 'Kamu adalah "Suster Care", asisten kesehatan ISK (Infeksi Saluran Kemih) '
        'untuk remaja putri dalam aplikasi UtiCare. '
        'Jawab dengan bahasa yang ramah, empati, dan mudah dipahami remaja. '
        'ATURAN: Kamu HANYA boleh menjawab pertanyaan seputar ISK, kesehatan saluran kemih, '
        'kebersihan area genital, kebiasaan minum air, dan topik kesehatan terkait. '
        'Jika ditanya di luar topik kesehatan (pemrograman, matematika, dll), tolak dengan sopan. '
        'Jangan berikan diagnosis medis berat. Sarankan ke tenaga kesehatan jika gejala serius. '
        'Maksimal 3-4 kalimat per jawaban kecuali pengguna minta penjelasan detail.'
        '$userContext';

    final List<Map<String, dynamic>> messages = [
      {'role': 'system', 'content': systemPrompt},
      ...chatHistory,
    ];

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String?;
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
      } else {
        debugPrint('OpenAI Chat API Error: ${response.statusCode}');
        return 'Ada sedikit kendala koneksi. Coba lagi nanti ya.';
      }
    } catch (e) {
      debugPrint('Chat AI error: $e');
      return 'Kesulitan memproses pesanmu karena masalah jaringan. Coba lagi.';
    }

    return 'Maaf, aku belum bisa menjawab pertanyaanmu saat ini.';
  }
}
