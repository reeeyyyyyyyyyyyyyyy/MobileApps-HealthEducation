import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'time_helper.dart';

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

  static Future<Map<String, dynamic>?> _getUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        return data;
      }
    } catch (e) {
      debugPrint('Error fetching user profile for AI: $e');
    }
    return null;
  }

  static Future<String> chatWithAI(List<Map<String, String>> chatHistory) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return "Maaf, aku lagi nggak bisa terhubung ke server nih. Pastikan API Key sudah diset ya! 🌸";
    }

    final today = TimeHelper.nowWIB();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final List<String> weekdays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final weekdayStr = weekdays[today.weekday - 1];
    final monthStr = months[today.month - 1];
    final todayReadable = "$weekdayStr, ${today.day} $monthStr ${today.year}";

    String userContext = "";
    final profile = await _getUserProfile();
    if (profile != null) {
      final String name = profile['full_name'] as String? ?? 'Bloom';
      final bool? hasMenstruated = profile['has_menstruated'] as bool?;
      final String? lastPeriodDateStr = profile['last_period_date'] as String?;
      final int avgPeriodDuration = profile['avg_period_duration'] as int? ?? 5;
      final int avgCycleLength = profile['avg_cycle_length'] as int? ?? 28;

      userContext += "\n\nINFORMASI DATA PENGGUNA SAAT INI:";
      userContext += "\n- Nama Panggilan: $name";
      userContext += "\n- Hari ini tanggal: $todayReadable ($todayStr)";
      
      if (hasMenstruated == false) {
        userContext += "\n- Status Haid: Pengguna belum pernah menstruasi.";
      } else if (hasMenstruated == true) {
        userContext += "\n- Status Haid: Sudah pernah menstruasi.";
        userContext += "\n- Durasi Haid Rata-rata: $avgPeriodDuration hari";
        userContext += "\n- Panjang Siklus Rata-rata: $avgCycleLength hari";
        
        if (lastPeriodDateStr != null) {
          final lastPeriodDate = DateTime.tryParse(lastPeriodDateStr);
          if (lastPeriodDate != null) {
            final lastPeriodReadable = "${lastPeriodDate.day} ${months[lastPeriodDate.month - 1]} ${lastPeriodDate.year}";
            userContext += "\n- Tanggal Haid Terakhir Mulai: $lastPeriodReadable ($lastPeriodDateStr)";
            
            final todayWithoutTime = DateTime(today.year, today.month, today.day);
            final lastPeriodWithoutTime = DateTime(lastPeriodDate.year, lastPeriodDate.month, lastPeriodDate.day);
            
            DateTime predictionDate = lastPeriodWithoutTime.add(Duration(days: avgCycleLength));
            
            // Fast-forward prediction date to current/next cycle if it's completely in the past
            while (predictionDate.add(Duration(days: avgPeriodDuration)).isBefore(todayWithoutTime)) {
              predictionDate = predictionDate.add(Duration(days: avgCycleLength));
            }
            
            final target = DateTime(predictionDate.year, predictionDate.month, predictionDate.day);
            final difference = target.difference(todayWithoutTime).inDays;
            
            final currentPeriodDay = todayWithoutTime.difference(lastPeriodWithoutTime).inDays + 1;
            final isCurrentlyInPeriod = (currentPeriodDay >= 1 && currentPeriodDay <= avgPeriodDuration);
            
            if (isCurrentlyInPeriod) {
              userContext += "\n- Kondisi Haid Hari Ini: Sedang berlangsung (Hari ke-$currentPeriodDay dari perkiraan $avgPeriodDuration hari).";
            } else if (difference > 0) {
              userContext += "\n- Kondisi Haid Hari Ini: H-$difference menjelang haid berikutnya (kurang $difference hari lagi).";
            } else if (difference == 0) {
              userContext += "\n- Kondisi Haid Hari Ini: Perkiraan haid berikutnya mulai HARI INI.";
            } else {
              final lateDays = difference.abs();
              userContext += "\n- Kondisi Haid Hari Ini: Terlambat haid $lateDays hari dari perkiraan.";
            }
            
            // Next 3 predicted cycles
            userContext += "\n- Jadwal Prediksi Siklus-Siklus Berikutnya:";
            DateTime tempPrediction = predictionDate;
            for (int i = 1; i <= 3; i++) {
              final tempStartReadable = "${tempPrediction.day} ${months[tempPrediction.month - 1]} ${tempPrediction.year}";
              final tempEnd = tempPrediction.add(Duration(days: avgPeriodDuration - 1));
              final tempEndReadable = "${tempEnd.day} ${months[tempEnd.month - 1]} ${tempEnd.year}";
              userContext += "\n  * Siklus ke-$i: Perkiraan Mulai $tempStartReadable s/d Selesai $tempEndReadable";
              tempPrediction = tempPrediction.add(Duration(days: avgCycleLength));
            }
          }
        } else {
          userContext += "\n- Catatan: Pengguna belum mencatat tanggal haid terakhirnya.";
        }
      } else {
        userContext += "\n- Status: Data menstruasi belum disetup oleh pengguna.";
      }
    } else {
      userContext += "\n- Hari ini tanggal: $todayReadable ($todayStr)";
      userContext += "\n- Catatan: Data profil pengguna tidak ditemukan di database.";
    }

    final String systemPrompt = "Kamu adalah 'BloomFem Assistant', sahabat dan konsultan kesehatan reproduksi remaja perempuan. Jawab dengan bahasa gaul, ramah, dan empatik. "
        "ATURAN MUTLAK: Kamu HANYA boleh menjawab pertanyaan seputar menstruasi, pubertas, kebersihan intim, dan kesehatan mental remaja. Jika ditanya tentang pemrograman (koding/SQL/Python), hitungan matematika kompleks, atau hal di luar kesehatan reproduksi, TOLAK dengan sopan dan katakan kamu hanya bisa membahas kesehatan perempuan. Jangan beri resep obat keras. "
        "Jika pengguna curhat atau berkonsultasi mengenai durasi haid yang sangat singkat (misalnya 1 atau 2 hari saja / kurang dari 3 hari), berikan penjelasan medis ringan secara sangat jelas, menenangkan, empati, dan edukatif tentang faktor penyebabnya pada remaja (seperti stres, kelelahan, perubahan berat badan, diet, atau hormonal imbalance yang wajar terjadi di awal pubertas). Berikan saran agar mereka memantau terus siklus haidnya dan berkonsultasi ke dokter jika terjadi berulang kali. "
        "PENTING: Gunakan informasi data pribadi pengguna di bawah ini untuk menjawab secara spesifik dan personal ketika ditanya mengenai status, tanggal haid terakhir, perkiraan haid berikutnya, atau kapan haid bulan depan. Jangan menyuruh pengguna menggunakan aplikasi lain atau membuka menu lain untuk melihat data ini. Kamu harus menganalisis data ini dan memberikan jawaban langsung kepada pengguna. "
        "$userContext";

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
        debugPrint('OpenAI Chat API Error: ${response.statusCode} - ${response.body}');
        return "Aduh, sepertinya ada sedikit kendala koneksi nih. Coba lagi nanti ya! 🌸";
      }
    } catch (e) {
      debugPrint('Failed to fetch AI chat: $e');
      return "Waduh, aku kesulitan memproses pesanmu karena masalah jaringan. Coba lagi ya! 🌸";
    }

    return "Maaf ya, aku belum bisa menjawab pertanyaanmu saat ini. 🌸";
  }
}
