#!/usr/bin/env php
<?php
/**
 * BloomFem — Database Reset & Seed
 * 
 * Usage from project root:
 *   php bin/reseed.php
 * 
 * This will:
 * 1. Clear all modules, paths, quizzes, questions, bookmarks
 * 2. Create 3 learning paths with correct sort_order
 * 3. Create 9 modules (3 per path, one per category)
 * 4. Create 3 quizzes (one per path) with questions
 */

require __DIR__ . '/../admin_dashboard/vendor/autoload.php';

$app = require __DIR__ . '/../admin_dashboard/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;
use App\Models\Module;
use App\Models\Quiz;
use App\Models\Question;

echo "=== BloomFem Database Reset & Seed ===\n\n";

// Step 1: Clean
echo "Clearing existing data...\n";
DB::statement('SET session_replication_role = replica;'); // disable FK checks for PostgreSQL
DB::table('learning_path_modules')->delete();
DB::table('learning_paths')->delete();
DB::table('questions')->delete();
DB::table('quizzes')->delete();
DB::table('user_quizzes')->delete();
DB::table('user_bookmarks')->delete();
DB::table('user_tip_views')->delete();
DB::table('daily_tips')->delete();
DB::table('daily_logs')->delete();
DB::table('modules')->whereNull('scheduled_at')->orWhere('scheduled_at', '<=', now())->delete();
DB::statement('SET session_replication_role = DEFAULT;');
echo "  ✓ Cleared.\n";

// Step 2: Content templates
$long = '<h2>Pendahuluan</h2><p>Siklus menstruasi adalah proses alami yang dialami setiap remaja putri. Proses ini melibatkan perubahan hormonal yang kompleks dan mempersiapkan tubuh untuk kemungkinan kehamilan. Memahami siklus ini sangat penting untuk menjaga kesehatan reproduksi.</p><h3>Apa yang Terjadi?</h3><p>Setiap bulan, ovarium melepaskan sel telur (ovulasi). Jika tidak terjadi pembuahan, lapisan rahim akan luruh dan keluar sebagai darah menstruasi. Ini adalah proses yang sehat dan normal.</p><p>Dengan memahami siklus menstruasi, kamu bisa lebih percaya diri dan siap menghadapi perubahan tubuhmu. Teruslah belajar dan jaga kesehatan reproduksimu!</p>';

$med = '<p>Kebersihan saat menstruasi sangat penting untuk mencegah infeksi dan iritasi. Ganti pembalut setiap 4-6 jam, cuci tangan sebelum dan sesudah mengganti, gunakan celana dalam yang bersih dan nyaman. Mandi secara teratur membantu menjaga kebersihan dan membuat tubuh terasa segar.</p>';

$short = '<p>Setiap perubahan tubuh saat pubertas adalah tanda kamu tumbuh sehat. Banggalah dengan dirimu sendiri. Kamu cantik apa adanya. Jangan membandingkan dirimu dengan orang lain. Setiap gadis berkembang dengan cara dan waktu yang berbeda.</p>';

// Helper to create a module
function createModule($title, $category, $duration, $icon, $content, $published = true) {
    return Module::create([
        'title' => $title,
        'category' => $category,
        'duration' => $duration,
        'icon_name' => $icon,
        'content' => $content,
        'published' => $published ? 1 : 0,
    ]);
}

// Step 3: Create Learning Paths with CORRECT sort_order
echo "Creating learning paths...\n";

// Path 1: Dasar Menstruasi (sort_order = 1)
$path1 = DB::table('learning_paths')->insertGetId([
    'title' => 'Dasar Menstruasi',
    'description' => 'Pelajari fundamental tentang siklus menstruasi',
    'icon' => 'menu_book',
    'sort_order' => 1,
]);

$m1 = createModule('Apa itu Menstruasi?',    'Pengetahuan',    '8 Menit', 'water_drop_rounded',        $long);
$m2 = createModule('Kelola Nyeri Haid',      'Perilaku Sehat', '5 Menit', 'volunteer_activism_rounded', $med);
$m3 = createModule('Sikap Saat Menstruasi',  'Sikap Positif',  '3 Menit', 'favorite_rounded',          $short);

DB::table('learning_path_modules')->insert([
    ['path_id' => $path1, 'module_id' => $m1->id, 'sort_order' => 1],
    ['path_id' => $path1, 'module_id' => $m2->id, 'sort_order' => 2],
    ['path_id' => $path1, 'module_id' => $m3->id, 'sort_order' => 3],
]);
echo "  ✓ Path 1: Dasar Menstruasi (sort_order=1) — 3 modules\n";

// Path 2: Kesehatan Reproduksi (sort_order = 2)
$path2 = DB::table('learning_paths')->insertGetId([
    'title' => 'Kesehatan Reproduksi',
    'description' => 'Jaga kebersihan dan kesehatan organ intim',
    'icon' => 'clean_hands',
    'sort_order' => 2,
]);

$m4 = createModule('Kebersihan Saat Haid',  'Perilaku Sehat', '7 Menit', 'clean_hands_rounded',    $long);
$m5 = createModule('Nutrisi untuk Remaja',  'Pengetahuan',    '6 Menit', 'restaurant_rounded',     $med);
$m6 = createModule('Bangga dengan Tubuhmu', 'Sikap Positif',  '4 Menit', 'favorite_rounded',       $short);

DB::table('learning_path_modules')->insert([
    ['path_id' => $path2, 'module_id' => $m4->id, 'sort_order' => 1],
    ['path_id' => $path2, 'module_id' => $m5->id, 'sort_order' => 2],
    ['path_id' => $path2, 'module_id' => $m6->id, 'sort_order' => 3],
]);
echo "  ✓ Path 2: Kesehatan Reproduksi (sort_order=2) — 3 modules\n";

// Path 3: Siklus & Hormon (sort_order = 3)
$path3 = DB::table('learning_paths')->insertGetId([
    'title' => 'Siklus & Hormon',
    'description' => 'Pahami perubahan hormonal dalam siklus',
    'icon' => 'biotech',
    'sort_order' => 3,
]);

$m7 = createModule('Hormon & Emosi',        'Pengetahuan',    '10 Menit', 'biotech_rounded',       $long);
$m8 = createModule('Olahraga Saat Haid',    'Perilaku Sehat', '5 Menit',  'fitness_center_rounded', $med);
$m9 = createModule('Percaya Diri',          'Sikap Positif',  '3 Menit',  'psychology_rounded',     $short);

DB::table('learning_path_modules')->insert([
    ['path_id' => $path3, 'module_id' => $m7->id, 'sort_order' => 1],
    ['path_id' => $path3, 'module_id' => $m8->id, 'sort_order' => 2],
    ['path_id' => $path3, 'module_id' => $m9->id, 'sort_order' => 3],
]);
echo "  ✓ Path 3: Siklus & Hormon (sort_order=3) — 3 modules\n";

// Step 4: Create quizzes for each path
echo "Creating quizzes...\n";

$quiz1 = Quiz::create([
    'module_id' => $m1->id,
    'title' => 'Kuis Pemahaman Menstruasi Dasar',
    'xp_reward' => 100,
]);

Question::create([
    'quiz_id' => $quiz1->id,
    'question_text' => 'Berapa rata-rata panjang siklus menstruasi yang normal?',
    'options' => ['10-15 hari', '21-35 hari', '40-50 hari', '60 hari'],
    'correct_index' => 1,
    'explanation' => 'Siklus menstruasi yang normal berkisar antara 21 hingga 35 hari.',
]);

Question::create([
    'quiz_id' => $quiz1->id,
    'question_text' => 'Apa yang terjadi jika sel telur tidak dibuahi?',
    'options' => ['Langsung hamil', 'Dinding rahim luruh', 'Tidak terjadi apa-apa', 'Sel telur tetap di ovarium'],
    'correct_index' => 1,
    'explanation' => 'Jika tidak terjadi pembuahan, dinding rahim akan luruh sebagai menstruasi.',
]);

echo "  ✓ Quiz 1: Kuis Pemahaman Menstruasi Dasar (100 XP)\n";

// Verify
echo "\n=== Verification ===\n";
$paths = DB::table('learning_paths')->orderBy('sort_order')->get();
foreach ($paths as $p) {
    $count = DB::table('learning_path_modules')->where('path_id', $p->id)->count();
    echo "  [{$p->sort_order}] {$p->title} — {$count} modules\n";
}

$totalModules = Module::where('published', 1)->count();
$totalQuizzes = Quiz::count();
$totalQuestions = Question::count();
echo "\n  Total published modules: {$totalModules}\n";
echo "  Total quizzes: {$totalQuizzes}\n";
echo "  Total questions: {$totalQuestions}\n";
echo "\n=== Seed complete! ===\n";
