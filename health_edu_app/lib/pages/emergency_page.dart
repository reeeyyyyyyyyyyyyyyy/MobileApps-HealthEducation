import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  final List<EmergencyContact> _contacts = [
    EmergencyContact(
      name: 'SAHABAT PEREMPUAN',
      phone: '021-80600400',
      description: 'Layanan konseling & pendampingan untuk perempuan dan anak korban kekerasan.',
      category: 'Kekerasan & Darurat',
      icon: Icons.support_agent_rounded,
      color: Color(0xFFEF4444),
    ),
    EmergencyContact(
      name: 'SAPA (Sahabat Perempuan & Anak)',
      phone: '129',
      description: 'Hotline nasional Kementerian PPA untuk pengaduan kekerasan terhadap perempuan dan anak. Bebas pulsa, 24 jam.',
      category: 'Kekerasan & Darurat',
      icon: Icons.local_phone_rounded,
      color: Color(0xFFEF4444),
    ),
    EmergencyContact(
      name: 'Yayasan Pulih',
      phone: '021-78842580',
      description: 'Layanan konseling & pendampingan psikososial untuk korban kekerasan & trauma.',
      category: 'Konseling & Psikolog',
      icon: Icons.psychology_rounded,
      color: Color(0xFF8B5CF6),
    ),
    EmergencyContact(
      name: 'LPSK (Perlindungan Saksi & Korban)',
      phone: '021-29570888',
      description: 'Lembaga perlindungan saksi dan korban untuk mendapatkan bantuan hukum dan medis.',
      category: 'Bantuan Hukum',
      icon: Icons.gavel_rounded,
      color: Color(0xFF3B82F6),
    ),
    EmergencyContact(
      name: 'Call Center Darurat Nasional',
      phone: '112',
      description: 'Nomor darurat nasional untuk segala keadaan darurat (polisi, ambulans, pemadam). Bebas pulsa, 24 jam.',
      category: 'Darurat Umum',
      icon: Icons.emergency_rounded,
      color: Color(0xFFEF4444),
    ),
    EmergencyContact(
      name: 'Hotline HIV/AIDS (Kemenkes)',
      phone: '021-5212111',
      description: 'Informasi & konseling terkait HIV/AIDS, tes, dan pengobatan.',
      category: 'Kesehatan Reproduksi',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFF10B981),
    ),
    EmergencyContact(
      name: 'PKBI (Perkumpulan Keluarga Berencana Indonesia)',
      phone: '021-3913471',
      description: 'Konseling & edukasi kesehatan reproduksi, kontrasepsi, dan kesehatan seksual untuk remaja.',
      category: 'Kesehatan Reproduksi',
      icon: Icons.favorite_rounded,
      color: Color(0xFF10B981),
    ),
    EmergencyContact(
      name: 'Halodoc',
      phone: '021-50959990',
      description: 'Aplikasi konsultasi dokter online, chat dengan dokter, beli obat, dan cek lab. Tersedia kategoris kesehatan umum termasuk kesehatan reproduksi.',
      category: 'Konsultasi Online',
      icon: Icons.phone_android_rounded,
      color: Color(0xFF0EA5E9),
    ),
    EmergencyContact(
      name: 'Alodokter',
      phone: null,
      description: 'Platform konsultasi kesehatan online. Chat dengan dokter umum & spesialis kandungan. Tersedia di Play Store & App Store.',
      category: 'Konsultasi Online',
      icon: Icons.chat_rounded,
      color: Color(0xFF0EA5E9),
    ),
  ];

  Set<String> _expandedCategories = {};

  @override
  Widget build(BuildContext context) {
    final categories = _contacts.map((c) => c.category).toSet().toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kontak & Bantuan Darurat',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
        ),
        shape: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Banner peringatan
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFEF2F2), Color(0xFFFFE4E4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFFECACA), width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dalam Keadaan Darurat?',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Jika kamu dalam situasi berbahaya atau darurat medis, segera hubungi 112 atau kontak di bawah ini.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Daftar kontak per kategori
          for (final category in categories) ...[
            _buildCategorySection(category),
            SizedBox(height: 12),
          ],

          SizedBox(height: 20),

          // Tips keamanan
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Keamanan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                SizedBox(height: 12),
                _buildTipItem(Icons.people_rounded, 'Beri tahu orang tua atau teman terpercaya ke mana kamu pergi.'),
                _buildTipItem(Icons.phone_in_talk_rounded, 'Simpan nomor darurat di kontak cepat ponselmu.'),
                _buildTipItem(Icons.map_rounded, 'Kenali rute aman dan lokasi klinik terdekat dari rumah/sekolah.'),
                _buildTipItem(Icons.shield_rounded, 'Percaya instingmu — jika merasa tidak aman, segera cari bantuan.'),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Disclaimer
          Text(
            'Informasi kontak ini dikumpulkan dari sumber terbuka dan dapat berubah sewaktu-waktu. BloomFem tidak terafiliasi dengan lembaga-lembaga tersebut.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: textSecondary),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final categoryContacts = _contacts.where((c) => c.category == category).toList();
    final isExpanded = _expandedCategories.contains(category) || categoryContacts.length <= 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCategories.remove(category);
                } else {
                  _expandedCategories.add(category);
                }
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: categoryContacts.first.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    category,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary),
                  ),
                  Spacer(),
                  if (categoryContacts.length > 1)
                    Icon(
                      isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: textSecondary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: Color(0xFFF1F5F9)),
            for (final contact in categoryContacts)
              _buildContactCard(contact),
          ],
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return InkWell(
      onTap: () => _showContactDialog(contact),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: contact.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(contact.icon, color: contact.color, size: 22),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                  SizedBox(height: 2),
                  Text(contact.description, style: TextStyle(fontSize: 11, color: textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (contact.phone != null) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.phone_rounded, color: Color(0xFF059669), size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showContactDialog(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: contact.color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(contact.icon, color: contact.color, size: 32),
              ),
              SizedBox(height: 12),
              Text(contact.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
              SizedBox(height: 8),
              Text(contact.description, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: textSecondary)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: contact.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(30)),
                child: Text(contact.category, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: contact.color)),
              ),
              if (contact.phone != null) ...[
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri.parse('tel:${contact.phone}')),
                    icon: Icon(Icons.phone_rounded, size: 18),
                    label: Text('Hubungi ${contact.phone}', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF059669),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: primaryColor),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: textSecondary, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class EmergencyContact {
  final String name;
  final String? phone;
  final String description;
  final String category;
  final IconData icon;
  final Color color;

  const EmergencyContact({
    required this.name,
    this.phone,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
  });
}
