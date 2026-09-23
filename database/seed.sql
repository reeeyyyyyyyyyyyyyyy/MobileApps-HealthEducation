-- ============================================
-- UtiCare Seed Data
-- Konten placeholder realistis untuk demo
-- ============================================

-- === REMINDER TEMPLATES ===
INSERT INTO reminder_templates (title, description, default_time, icon_name, sort_order) VALUES
('Minum Air Putih', 'Minum minimal 8 gelas air putih per hari untuk menjaga kesehatan saluran kemih', '07:00:00', 'water_drop', 1),
('Jangan Menahan BAK', 'Ingatkan dirimu untuk tidak menahan buang air kecil terlalu lama', '09:00:00', 'wc', 2),
('Kebersihan Area Genital', 'Jaga kebersihan area genital, bersihkan dari depan ke belakang', '06:00:00', 'clean_hands', 3),
('Aktivitas Fisik', 'Lakukan aktivitas fisik ringan minimal 30 menit per hari', '17:00:00', 'fitness_center', 4),
('Minum Air Sore', 'Jangan lupa minum air putih di sore hari untuk menjaga hidrasi', '15:00:00', 'local_drink', 5);

-- === EDUCATION MATERIALS ===
-- Perceived Susceptibility
INSERT INTO education_materials (title, category, content, hbm_component, published, sort_order) VALUES
('Apa itu ISK?', 'pengetahuan_isk', 'Infeksi Saluran Kemih (ISK) adalah infeksi yang terjadi di saluran kemih, termasuk ginjal, ureter, kandung kemih, dan uretra. ISK paling sering terjadi di bagian bawah saluran kemih, yaitu kandung kemih dan uretra.

ISK terjadi ketika bakteri masuk ke saluran kemih melalui uretra dan mulai berkembang biak di kandung kemih. Meskipun sistem kemih dirancang untuk mencegah masuknya bakteri, pertahanan ini terkadang gagal.

Remaja putri lebih rentan terkena ISK karena uretra perempuan lebih pendek dibandingkan laki-laki, sehingga bakteri lebih mudah mencapai kandung kemih. Selain itu, kebiasaan sehari-hari seperti menahan buang air kecil dan kurang minum air putih dapat meningkatkan risiko.

Gejala ISK yang umum meliputi: rasa ingin buang air kecil terus-menerus, sensasi terbakar saat buang air kecil, urine keruh atau berbau tajam, dan nyeri di perut bagian bawah.', 'perceived_susceptibility', 1, 1),

('Seberapa Besar Risiko Remaja Terkena ISK?', 'pengetahuan_isk', 'Menurut data kesehatan, sekitar 8% perempuan mengalami ISK setidaknya sekali dalam hidup mereka, dan remaja putri termasuk kelompok yang berisiko.

Beberapa faktor yang meningkatkan risiko ISK pada remaja putri:
- Menahan buang air kecil terlalu lama (terutama di sekolah)
- Kurang minum air putih
- Cara membersihkan area genital yang salah (dari belakang ke depan)
- Menggunakan pakaian dalam yang terlalu ketat
- Kurang menjaga kebersihan area genital saat menstruasi

Penting untuk menyadari bahwa ISK bukan penyakit yang memalukan. ISK adalah kondisi medis yang umum dan dapat dicegah dengan kebiasaan sehat sehari-hari.', 'perceived_susceptibility', 1, 2);

-- Perceived Severity
INSERT INTO education_materials (title, category, content, hbm_component, published, sort_order) VALUES
('Dampak ISK Jika Tidak Ditangani', 'pengetahuan_isk', 'ISK yang tidak ditangani dengan baik dapat menyebabkan komplikasi serius:

1. Infeksi Ginjal (Pielonefritis): Jika bakteri dari kandung kemih naik ke ginjal, dapat menyebabkan infeksi ginjal yang lebih berbahaya, disertai demam tinggi, nyeri punggung, dan mual.

2. ISK Berulang: Jika tidak diobati tuntas, ISK dapat kambuh berulang kali, mengganggu aktivitas sehari-hari dan kualitas hidup.

3. Sepsis: Dalam kasus yang jarang terjadi, infeksi dapat menyebar ke aliran darah dan menyebabkan kondisi yang mengancam jiwa.

4. Gangguan Aktivitas: ISK menyebabkan rasa tidak nyaman yang mengganggu konsentrasi belajar, aktivitas olahraga, dan interaksi sosial.

Kabar baiknya, ISK dapat dicegah dengan kebiasaan sehat yang sederhana dan mudah dilakukan setiap hari.', 'perceived_severity', 1, 3),

('Komplikasi ISK pada Remaja', 'pengetahuan_isk', 'Remaja yang mengalami ISK berulang dapat menghadapi berbagai dampak:

Dampak Fisik:
- Nyeri dan ketidaknyamanan berkepanjangan
- Demam dan kelelahan yang mengganggu aktivitas sekolah
- Risiko kerusakan ginjal jika infeksi menyebar

Dampak Psikologis:
- Rasa malu dan enggan membicarakan masalah kesehatan
- Kecemasan saat buang air kecil
- Mengurangi kepercayaan diri

Dampak Sosial:
- Sering absen dari sekolah
- Tidak bisa mengikuti kegiatan olahraga atau ekstrakurikuler
- Mengganggu pergaulan dan aktivitas bersama teman

Memahami dampak ini bukan untuk menakut-nakuti, tetapi untuk memotivasi kamu melakukan pencegahan sejak dini.', 'perceived_severity', 1, 4);

-- Perceived Benefits
INSERT INTO education_materials (title, category, content, hbm_component, published, sort_order) VALUES
('Manfaat Minum Air Putih Cukup', 'pencegahan', 'Minum air putih yang cukup (minimal 8 gelas per hari) memiliki banyak manfaat untuk kesehatan saluran kemihmu:

1. Membersihkan Bakteri: Air putih membantu mengalirkan bakteri keluar dari saluran kemih melalui urine, sehingga bakteri tidak sempat berkembang biak.

2. Mengencerkan Urine: Urine yang encer dan berwarna jernih menandakan tubuh terhidrasi dengan baik, mengurangi iritasi pada saluran kemih.

3. Meningkatkan Frekuensi BAK: Semakin sering buang air kecil, semakin sedikit kesempatan bakteri untuk tinggal di kandung kemih.

4. Menjaga Kesehatan Kulit: Hidrasi yang baik juga berdampak pada kesehatan kulit dan metabolisme tubuh.

Tips praktis: Bawa botol minum ke sekolah, set pengingat di HP untuk minum air, dan biasakan minum segelas air setelah bangun tidur.', 'perceived_benefits', 1, 5),

('Keuntungan Menjaga Kebersihan Area Genital', 'kebersihan', 'Menjaga kebersihan area genital dengan benar memberikan perlindungan berlapis terhadap ISK:

Cara membersihkan yang benar:
- Selalu bersihkan dari DEPAN ke BELAKANG (dari vagina ke anus), bukan sebaliknya
- Gunakan air bersih, hindari sabun beraroma keras
- Keringkan area genital setelah membersihkan
- Ganti pakaian dalam minimal 2 kali sehari

Manfaat yang didapat:
- Mencegah bakteri dari area anus berpindah ke uretra
- Menjaga keseimbangan pH alami vagina
- Mengurangi risiko infeksi hingga 50%
- Merasa lebih nyaman dan percaya diri

Kebiasaan ini sederhana tetapi sangat efektif dalam mencegah ISK dan menjaga kesehatan reproduksimu.', 'perceived_benefits', 1, 6);

-- Perceived Barriers
INSERT INTO education_materials (title, category, content, hbm_component, published, sort_order) VALUES
('Mengatasi Malas Minum Air', 'pencegahan', 'Banyak remaja kesulitan minum air putih yang cukup. Berikut tips mengatasinya:

Kenali alasan umum:
- "Lupa minum" - Solusi: Set pengingat di HP atau gunakan aplikasi UtiCare
- "Tidak suka air putih" - Solusi: Tambahkan irisan lemon, mentimun, atau buah segar
- "Takut sering ke toilet di sekolah" - Solusi: Ini justru tanda baik! Sering BAK membantu mencegah ISK
- "Tidak bawa botol minum" - Solusi: Jadikan botol minum bagian dari perlengkapan wajib

Strategi praktis:
- Minum 1 gelas air setelah bangun tidur
- Bawa botol minum 600ml ke sekolah, habiskan 2x sehari
- Minum 1 gelas sebelum dan sesudah makan
- Minum 1 gelas sebelum tidur
- Total: sudah 8 gelas!

Ingat, tubuhmu membutuhkan air untuk bekerja dengan baik.', 'perceived_barriers', 1, 7),

('Tips Kebersihan Area Genital di Sekolah', 'kebersihan', 'Menjaga kebersihan area genital di sekolah memang bisa terasa sulit, tapi bukan tidak mungkin:

Persiapan dari rumah:
- Bawa tisu basah tanpa pewangi di tas
- Siapkan pakaian dalam cadangan
- Bawa kantong plastik kecil untuk pakaian dalam kotor

Saat di sekolah:
- Manfaatkan waktu istirahat untuk ke toilet
- Bersihkan area genital setiap kali BAK
- Selalu bersihkan dari depan ke belakang
- Cuci tangan sebelum dan sesudah ke toilet

Saat menstruasi:
- Ganti pembalut setiap 3-4 jam
- Bersihkan area genital saat mengganti pembalut
- Bawa perlengkapan cadangan di tas

Jangan malu untuk ke toilet saat diperlukan. Kesehatan saluran kemihmu lebih penting!', 'perceived_barriers', 1, 8);

-- Cues to Action
INSERT INTO education_materials (title, category, content, hbm_component, published, sort_order) VALUES
('Tanda-tanda Awal ISK', 'pengetahuan_isk', 'Kenali tanda-tanda awal ISK agar bisa segera ditangani:

Gejala yang perlu diwaspadai:
- Sering ingin buang air kecil meskipun urine sedikit
- Sensasi terbakar atau perih saat buang air kecil
- Urine berwarna keruh, gelap, atau berbau tajam
- Nyeri atau tekanan di perut bagian bawah
- Merasa lelah tanpa sebab yang jelas

Tanda ISK yang lebih serius (segera ke dokter):
- Demam di atas 38 derajat Celsius
- Nyeri di punggung bawah atau samping
- Mual dan muntah
- Urine bercampur darah

Apa yang harus dilakukan:
1. Perbanyak minum air putih
2. Jangan menahan BAK
3. Beritahu orang tua atau guru
4. Segera konsultasi ke dokter atau puskesmas

Ingat, mendeteksi dini dan penanganan cepat mencegah komplikasi yang lebih serius.', 'cues_to_action', 1, 9),

('Kapan Harus ke Dokter?', 'pengetahuan_isk', 'Tidak semua keluhan saluran kemih memerlukan kunjungan dokter, tapi ada kondisi yang harus segera ditangani:

Segera ke dokter jika:
- Gejala ISK bertahan lebih dari 2 hari meskipun sudah banyak minum air
- Demam menyertai gejala buang air kecil
- Ada darah dalam urine
- Nyeri punggung bawah yang hebat
- Gejala ISK sering kambuh (lebih dari 2x dalam 6 bulan)

Ke mana harus pergi:
- Puskesmas terdekat (gratis dengan BPJS)
- Klinik dokter umum
- Rumah sakit (unit rawat jalan urologi)

Yang perlu disampaikan ke dokter:
- Sejak kapan gejala muncul
- Seberapa sering buang air kecil
- Warna dan bau urine
- Riwayat ISK sebelumnya
- Kebiasaan minum dan kebersihan

Jangan malu untuk konsultasi. Dokter dan perawat sudah terbiasa menangani kasus seperti ini.', 'cues_to_action', 1, 10);

-- Self-Efficacy
INSERT INTO education_materials (title, category, content, hbm_component, published, sort_order) VALUES
('Langkah Mudah Mencegah ISK', 'pencegahan', 'Mencegah ISK tidak sulit. Berikut langkah-langkah sederhana yang bisa kamu mulai hari ini:

5 Kebiasaan Utama Pencegahan ISK:

1. MINUM AIR PUTIH CUKUP
   Target: 8 gelas per hari (sekitar 2 liter)
   Caranya: Bawa botol minum ke mana-mana

2. JANGAN MENAHAN BAK
   Segera ke toilet saat terasa ingin buang air kecil
   Jangan tunda, meski sedang sibuk atau di kelas

3. BERSIHKAN DARI DEPAN KE BELAKANG
   Setelah buang air kecil atau besar
   Ini mencegah bakteri dari anus masuk ke uretra

4. GANTI PAKAIAN DALAM TERATUR
   Minimal 2 kali sehari
   Pilih bahan katun yang menyerap keringat

5. AKTIVITAS FISIK TERATUR
   Minimal 30 menit per hari
   Olahraga ringan meningkatkan imunitas tubuh

Semua langkah ini mudah dilakukan dan bisa kamu jadikan kebiasaan sehari-hari.', 'self_efficacy', 1, 11),

('Fakta Seputar ISK - Mitos atau Fakta?', 'fakta_mitos', 'Mari luruskan beberapa mitos tentang ISK:

MITOS: ISK hanya terjadi pada orang dewasa
FAKTA: Remaja putri juga sangat rentan terkena ISK

MITOS: Menahan BAK tidak berbahaya
FAKTA: Menahan BAK memberi kesempatan bakteri berkembang biak di kandung kemih

MITOS: Minum banyak air membuat sering ke toilet, jadi merepotkan
FAKTA: Sering buang air kecil justru membantu membersihkan bakteri dari saluran kemih

MITOS: ISK pasti butuh antibiotik
FAKTA: ISK ringan kadang bisa sembuh dengan banyak minum air, tapi tetap konsultasi dokter

MITOS: Membersihkan area genital dengan sabun wangi itu bersih
FAKTA: Sabun beraroma justru bisa mengganggu keseimbangan pH dan meningkatkan risiko infeksi

MITOS: ISK menular
FAKTA: ISK TIDAK menular dari orang ke orang. ISK disebabkan bakteri yang sudah ada di tubuh

Pengetahuan yang benar adalah langkah pertama pencegahan yang efektif.', 'self_efficacy', 1, 12);

-- === CHECK RISK QUESTIONS ===
INSERT INTO risk_questions (question_text, question_order) VALUES
('Seberapa sering kamu menahan buang air kecil?', 1),
('Berapa gelas air putih yang kamu minum setiap hari?', 2),
('Bagaimana cara kamu membersihkan area genital setelah buang air kecil?', 3),
('Seberapa sering kamu mengganti pakaian dalam?', 4),
('Apakah kamu melakukan aktivitas fisik/olahraga secara teratur?', 5),
('Seberapa sering kamu menggunakan toilet umum tanpa membersihkannya terlebih dahulu?', 6),
('Apakah kamu sering menggunakan pakaian dalam yang ketat?', 7),
('Seberapa sering kamu mengalami gejala seperti perih saat buang air kecil?', 8),
('Apakah kamu membersihkan area genital saat menstruasi secara teratur?', 9),
('Seberapa sering kamu minum minuman berkafein (kopi, teh, soda)?', 10);

-- Risk options for each question
-- Q1: Menahan BAK
INSERT INTO risk_options (question_id, option_text, score, option_order) VALUES
(1, 'Sering', 2, 1),
(1, 'Kadang-kadang', 1, 2),
(1, 'Jarang', 0, 3),
(1, 'Tidak pernah', 0, 4);

-- Q2: Minum air putih
INSERT INTO risk_options (question_id, option_text, score, option_order) VALUES
(2, '< 4 gelas', 2, 1),
(2, '4 - 7 gelas', 1, 2),
(2, '>= 8 gelas', 0, 3);

-- Q3: Cara membersihkan
INSERT INTO risk_options (question_id, option_text, score, option_order) VALUES
(3, 'Dari belakang ke depan', 2, 1),
(3, 'Tidak tentu arahnya', 1, 2),
(3, 'Dari depan ke belakang', 0, 3);

-- Q4: Ganti pakaian dalam
INSERT INTO risk_options (question_id, option_text, score, option_order) VALUES
(4, 'Sekali sehari atau kurang', 2, 1),
(4, '2 kali sehari', 0, 2),
(4, 'Lebih dari 2 kali sehari', 0, 3);

-- Q5: Aktivitas fisik
INSERT INTO risk_options (question_id, option_text, score, option_order) VALUES
(5, 'Jarang/tidak pernah', 2, 1),
(5, '1-2 kali seminggu', 1, 2),
(5, '3 kali atau lebih seminggu', 0, 3);

-- Q6: Toilet umum
INSERT INTO risk_options (question_id, option_text, score, option_order) VALUES
(6, 'Sering', 2, 1),
(6, 'Kadang-kadang', 1, 2),
(6, 'Jarang/tidak pernah', 0, 3);

-- Q7: Pakaian ketat
INSERT INTO risk_options (question_id, option_text, score, option_order) VALUES
(7, 'Sering', 2, 1),
(7, 'Kadang-kadang', 1, 2),
(7, 'Jarang/tidak pernah', 0, 3);

-- Q8: Gejala perih
INSERT INTO risk_options (question_id, option_text, score, option_order) VALUES
(8, 'Sering', 2, 1),
(8, 'Kadang-kadang', 1, 2),
(8, 'Tidak pernah', 0, 3);

-- Q9: Kebersihan saat menstruasi
INSERT INTO risk_options (question_id, option_text, score, option_order) VALUES
(9, 'Jarang', 2, 1),
(9, 'Kadang-kadang', 1, 2),
(9, 'Selalu', 0, 3);

-- Q10: Minuman berkafein
INSERT INTO risk_options (question_id, option_text, score, option_order) VALUES
(10, 'Setiap hari', 2, 1),
(10, 'Beberapa kali seminggu', 1, 2),
(10, 'Jarang/tidak pernah', 0, 3);

-- === SURVEY INSTRUMENTS (PRE-TEST & POST-TEST) ===
-- Likert options will be shared, created after instruments

-- PENGETAHUAN (10 items)
INSERT INTO survey_instruments (type, variable, question_text, question_order) VALUES
('pretest', 'pengetahuan', 'ISK adalah infeksi yang terjadi pada saluran kemih', 1),
('pretest', 'pengetahuan', 'Remaja putri lebih berisiko terkena ISK dibandingkan laki-laki', 2),
('pretest', 'pengetahuan', 'Menahan buang air kecil dapat meningkatkan risiko ISK', 3),
('pretest', 'pengetahuan', 'Minum air putih minimal 8 gelas per hari membantu mencegah ISK', 4),
('pretest', 'pengetahuan', 'Membersihkan area genital dari depan ke belakang adalah cara yang benar', 5),
('pretest', 'pengetahuan', 'ISK yang tidak ditangani dapat menyebabkan infeksi ginjal', 6),
('pretest', 'pengetahuan', 'Gejala ISK meliputi rasa perih saat buang air kecil dan urine keruh', 7),
('pretest', 'pengetahuan', 'Pakaian dalam yang ketat dapat meningkatkan risiko ISK', 8),
('pretest', 'pengetahuan', 'ISK dapat dicegah dengan kebiasaan kebersihan yang baik', 9),
('pretest', 'pengetahuan', 'ISK tidak menular dari satu orang ke orang lain', 10);

-- SIKAP (10 items)
INSERT INTO survey_instruments (type, variable, question_text, question_order) VALUES
('pretest', 'sikap', 'Saya merasa pencegahan ISK itu penting untuk kesehatan saya', 1),
('pretest', 'sikap', 'Saya percaya bahwa minum air putih cukup dapat mencegah ISK', 2),
('pretest', 'sikap', 'Saya bersedia meluangkan waktu untuk menjaga kebersihan area genital', 3),
('pretest', 'sikap', 'Saya merasa tidak malu untuk ke toilet saat diperlukan di sekolah', 4),
('pretest', 'sikap', 'Saya setuju bahwa menahan BAK itu berbahaya untuk kesehatan', 5),
('pretest', 'sikap', 'Saya percaya bahwa kebiasaan sehat sehari-hari lebih baik daripada pengobatan', 6),
('pretest', 'sikap', 'Saya bersedia berkonsultasi ke tenaga kesehatan jika mengalami gejala ISK', 7),
('pretest', 'sikap', 'Saya merasa edukasi tentang ISK penting diberikan kepada remaja', 8),
('pretest', 'sikap', 'Saya yakin bahwa saya bisa menerapkan kebiasaan pencegahan ISK', 9),
('pretest', 'sikap', 'Saya bersedia mengingatkan teman tentang pentingnya pencegahan ISK', 10);

-- PERILAKU (10 items)
INSERT INTO survey_instruments (type, variable, question_text, question_order) VALUES
('pretest', 'perilaku', 'Saya minum air putih minimal 8 gelas per hari', 1),
('pretest', 'perilaku', 'Saya tidak menahan buang air kecil saat terasa ingin', 2),
('pretest', 'perilaku', 'Saya membersihkan area genital dari depan ke belakang', 3),
('pretest', 'perilaku', 'Saya mengganti pakaian dalam minimal 2 kali sehari', 4),
('pretest', 'perilaku', 'Saya melakukan aktivitas fisik/olahraga secara teratur', 5),
('pretest', 'perilaku', 'Saya membersihkan toilet sebelum menggunakannya di tempat umum', 6),
('pretest', 'perilaku', 'Saya menggunakan pakaian dalam berbahan katun yang nyaman', 7),
('pretest', 'perilaku', 'Saya mencuci tangan sebelum dan sesudah ke toilet', 8),
('pretest', 'perilaku', 'Saya menjaga kebersihan area genital saat menstruasi secara teratur', 9),
('pretest', 'perilaku', 'Saya segera ke toilet saat merasa ingin buang air kecil meskipun sedang sibuk', 10);

-- Duplicate for POST-TEST (same questions)
INSERT INTO survey_instruments (type, variable, question_text, question_order)
SELECT 'posttest', variable, question_text, question_order
FROM survey_instruments
WHERE type = 'pretest';

-- Likert options for ALL survey instruments
DO $$
DECLARE
  inst_record RECORD;
BEGIN
  FOR inst_record IN SELECT id FROM survey_instruments LOOP
    INSERT INTO survey_options (instrument_id, option_text, score, option_order) VALUES
    (inst_record.id, 'Sangat Setuju', 5, 1),
    (inst_record.id, 'Setuju', 4, 2),
    (inst_record.id, 'Ragu-ragu', 3, 3),
    (inst_record.id, 'Tidak Setuju', 2, 4),
    (inst_record.id, 'Sangat Tidak Setuju', 1, 5);
  END LOOP;
END $$;

-- === DAILY TIPS ===
INSERT INTO daily_tips (title, content, category) VALUES
('Minum Air Setelah Bangun', 'Biasakan minum segelas air putih hangat setelah bangun tidur. Ini membantu memulai metabolisme dan membersihkan saluran kemih setelah semalaman tidak minum.', 'hidrasi'),
('Jangan Menahan BAK', 'Menahan buang air kecil memberi kesempatan bakteri untuk berkembang biak di kandung kemihmu. Segera ke toilet saat terasa ingin, jangan ditunda!', 'kebiasaan'),
('Bersihkan dari Depan ke Belakang', 'Saat membersihkan area genital setelah BAK atau BAB, selalu usap dari depan ke belakang. Ini mencegah bakteri dari area anus masuk ke uretra.', 'kebersihan'),
('Ganti Pakaian Dalam 2x Sehari', 'Pakaian dalam yang lembab menjadi tempat bakteri berkembang biak. Ganti minimal 2 kali sehari dan pilih bahan katun yang menyerap keringat.', 'kebersihan'),
('Olahraga Ringan 30 Menit', 'Aktivitas fisik teratur meningkatkan sistem imun tubuh. Cukup 30 menit jalan kaki, bersepeda, atau senam ringan setiap hari.', 'aktivitas'),
('Hindari Sabun Beraroma di Area Intim', 'Sabun wangi dan produk pembersih beraroma dapat mengganggu keseimbangan pH alami vagina. Cukup gunakan air bersih atau sabun khusus tanpa pewangi.', 'kebersihan'),
('Kenali Warna Urine', 'Urine yang sehat berwarna kuning pucat hingga jernih. Jika urinemu berwarna gelap atau keruh, mungkin kamu perlu minum lebih banyak air.', 'hidrasi'),
('Bawa Botol Minum ke Sekolah', 'Siapkan botol minum 600ml dan usahakan menghabiskannya 2 kali selama di sekolah. Ini sudah memenuhi setengah kebutuhan air harianmu!', 'hidrasi'),
('Buang Air Kecil Sebelum Tidur', 'Biasakan buang air kecil sebelum tidur untuk mengosongkan kandung kemih. Ini mengurangi risiko bakteri berkembang saat tidur.', 'kebiasaan'),
('Perhatikan Gejala Awal ISK', 'Jika kamu merasakan perih saat BAK, sering ingin BAK tapi sedikit, atau urine berbau tidak biasa, segera banyak minum air dan beritahu orang tua.', 'kesehatan'),
('Jangan Malu ke Toilet di Sekolah', 'Menahan BAK demi tidak mau ke toilet sekolah justru membahayakan kesehatanmu. Kesehatan saluran kemihmu lebih penting dari rasa malu.', 'kebiasaan'),
('Pilih Pakaian Dalam yang Nyaman', 'Hindari pakaian dalam yang terlalu ketat atau berbahan sintetis. Pilih yang longgar dan berbahan katun agar area genital tetap kering dan sehat.', 'kebersihan'),
('Minum Air Putih, Bukan Minuman Manis', 'Minuman manis dan berkafein tidak menggantikan air putih. Air putih adalah cara terbaik untuk menjaga hidrasi dan kesehatan saluran kemih.', 'hidrasi'),
('Cuci Tangan Sebelum ke Toilet', 'Sebelum dan sesudah ke toilet, cuci tanganmu dengan sabun dan air mengalir. Ini mencegah perpindahan bakteri ke area genital.', 'kebersihan'),
('Kamu Hebat Sudah Peduli Kesehatanmu', 'Langkah kecil yang kamu lakukan hari ini untuk menjaga kesehatan saluran kemihmu adalah investasi besar untuk masa depanmu. Tetap semangat!', 'motivasi');
