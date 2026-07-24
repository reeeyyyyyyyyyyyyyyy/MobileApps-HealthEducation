# BloomFem Database Tools

## Reseed Database

Menghapus semua data dan membuat ulang 3 learning paths + 9 modul + quizzes.

```bash
# From project root (bloomfem_project/):
php bin/reseed.php
```

### Yang di-reset:
| Tabel | Aksi |
|-------|------|
| `modules` | Dihapus & dibuat ulang (9 modul) |
| `learning_paths` | Dihapus & dibuat ulang (3 paths) |
| `learning_path_modules` | Dihapus & dibuat ulang |
| `quizzes` | Dihapus & dibuat ulang (3 quizzes) |
| `questions` | Dihapus & dibuat ulang (6 soal) |
| `user_bookmarks` | Dihapus |
| `user_tip_views` | Dihapus |
| `daily_tips` | Dihapus |
| `daily_logs` | Dihapus |

### Yang TIDAK di-reset:
| Tabel | Alasan |
|-------|--------|
| `profiles` | Data user |
| `user_quizzes` | Progress quiz user |
| `user_daily_visits` | Tracking kunjungan |
| `announcements` | Pengumuman admin |

### Learning Paths (setelah seed):
```
1. Dasar Menstruasi (unlocked)
   ├── Apa itu Menstruasi? (Pengetahuan)
   ├── Kelola Nyeri Haid (Perilaku Sehat)
   └── Sikap Saat Menstruasi (Sikap Positif)

2. Kesehatan Reproduksi (locked, unlock after path 1)
   ├── Kebersihan Saat Haid (Perilaku Sehat)
   ├── Nutrisi untuk Remaja (Pengetahuan)
   └── Bangga dengan Tubuhmu (Sikap Positif)

3. Siklus & Hormon (locked, unlock after path 2)
   ├── Hormon & Emosi (Pengetahuan)
   ├── Olahraga Saat Haid (Perilaku Sehat)
   └── Percaya Diri (Sikap Positif)
```
