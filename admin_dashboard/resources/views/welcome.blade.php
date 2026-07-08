<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>BloomFem — Portal Administrasi</title>
    <meta name="description"
        content="Sistem dasbor administrasi terpusat BloomFem untuk memoderasi forum komunitas, meninjau laporan, serta menganalisis statistik.">

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
        rel="stylesheet">

    <!-- Goey Toast -->
    <link rel="stylesheet" href="{{ asset('css/goey-toast.css') }}">

    <style>
        /* ── Reset & Base ────────────────────────────────────── */
        *,
        *::before,
        *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #fafbfc;
            color: #1a1a2e;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            -webkit-font-smoothing: antialiased;
            overflow-x: hidden;
        }

        ::selection {
            background: rgba(124, 58, 237, 0.15);
            color: #4c1d95;
        }

        /* ── Background Mesh ─────────────────────────────────── */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 0;
            pointer-events: none;
            background:
                radial-gradient(ellipse 800px 600px at 15% 10%, rgba(124, 58, 237, 0.06), transparent),
                radial-gradient(ellipse 600px 500px at 85% 80%, rgba(139, 92, 246, 0.04), transparent),
                radial-gradient(ellipse 400px 400px at 50% 50%, rgba(196, 181, 253, 0.03), transparent);
            animation: meshDrift 20s ease-in-out infinite alternate;
        }

        @keyframes meshDrift {
            0% {
                transform: translate(0, 0) scale(1);
            }

            100% {
                transform: translate(-20px, 10px) scale(1.05);
            }
        }

        /* ── Header ──────────────────────────────────────────── */
        .wl-header {
            position: relative;
            z-index: 1;
            width: 100%;
            max-width: 1120px;
            margin: 0 auto;
            padding: 28px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .wl-brand {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
        }

        .wl-brand-mark {
            width: 32px;
            height: 32px;
            border-radius: 10px;
            background: #7c3aed;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-weight: 800;
            font-size: 16px;
        }

        .wl-brand-text {
            font-weight: 800;
            font-size: 17px;
            letter-spacing: -0.02em;
            color: #1a1a2e;
        }

        .wl-header-nav a {
            display: inline-flex;
            align-items: center;
            padding: 9px 20px;
            font-size: 13.5px;
            font-weight: 600;
            border-radius: 10px;
            text-decoration: none;
            transition: all 0.2s ease;
        }

        .wl-btn-primary {
            background: #7c3aed;
            color: #fff;
            box-shadow: 0 2px 8px rgba(124, 58, 237, 0.2);
        }

        .wl-btn-primary:hover {
            background: #6d28d9;
            box-shadow: 0 4px 16px rgba(124, 58, 237, 0.3);
            transform: translateY(-1px);
        }

        .wl-btn-ghost {
            color: #475569;
        }

        .wl-btn-ghost:hover {
            background: rgba(124, 58, 237, 0.06);
            color: #7c3aed;
        }

        /* ── Hero ────────────────────────────────────────────── */
        .wl-hero {
            position: relative;
            z-index: 1;
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 60px 32px 40px;
        }

        .wl-hero-inner {
            max-width: 640px;
            text-align: center;
        }

        .wl-eyebrow {
            display: inline-block;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            color: #7c3aed;
            padding: 6px 16px;
            border: 1.5px solid rgba(124, 58, 237, 0.15);
            border-radius: 999px;
            margin-bottom: 28px;
            animation: wlFadeUp 0.6s ease-out both;
        }

        .wl-hero-title {
            font-size: clamp(36px, 5vw, 54px);
            font-weight: 800;
            letter-spacing: -0.035em;
            line-height: 1.1;
            color: #0f172a;
            animation: wlFadeUp 0.6s ease-out 0.1s both;
        }

        .wl-hero-title span {
            background: linear-gradient(135deg, #7c3aed, #a78bfa);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .wl-hero-desc {
            margin-top: 20px;
            font-size: 16px;
            line-height: 1.7;
            color: #64748b;
            max-width: 480px;
            margin-left: auto;
            margin-right: auto;
            animation: wlFadeUp 0.6s ease-out 0.2s both;
        }

        .wl-hero-actions {
            margin-top: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            animation: wlFadeUp 0.6s ease-out 0.3s both;
        }

        .wl-hero-actions a {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 13px 28px;
            font-size: 14px;
            font-weight: 700;
            border-radius: 12px;
            text-decoration: none;
            transition: all 0.2s ease;
        }

        .wl-cta-main {
            background: #7c3aed;
            color: #fff;
            box-shadow: 0 4px 16px rgba(124, 58, 237, 0.25);
        }

        .wl-cta-main:hover {
            background: #6d28d9;
            box-shadow: 0 8px 24px rgba(124, 58, 237, 0.35);
            transform: translateY(-2px);
        }

        .wl-cta-main:active {
            transform: translateY(0) scale(0.98);
        }

        .wl-cta-secondary {
            color: #475569;
            border: 1.5px solid #e2e8f0;
            background: #fff;
        }

        .wl-cta-secondary:hover {
            border-color: rgba(124, 58, 237, 0.3);
            color: #7c3aed;
            background: rgba(124, 58, 237, 0.03);
        }

        .wl-cta-secondary svg {
            transition: transform 0.2s ease;
        }

        .wl-cta-secondary:hover svg {
            transform: translateX(2px);
        }

        /* ── Features Grid ───────────────────────────────────── */
        .wl-features {
            position: relative;
            z-index: 1;
            max-width: 1120px;
            margin: 0 auto;
            padding: 20px 32px 60px;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            animation: wlFadeUp 0.6s ease-out 0.4s both;
        }

        .wl-feature-card {
            padding: 28px 24px;
            background: #ffffff;
            border: 1px solid rgba(226, 232, 240, 0.7);
            border-radius: 18px;
            transition: all 0.25s ease;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        }

        .wl-feature-card:hover {
            border-color: rgba(124, 58, 237, 0.2);
            box-shadow: 0 8px 30px -6px rgba(124, 58, 237, 0.08);
            transform: translateY(-3px);
        }

        .wl-feature-icon {
            width: 42px;
            height: 42px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 16px;
        }

        .wl-feature-title {
            font-size: 15px;
            font-weight: 700;
            letter-spacing: -0.01em;
            color: #0f172a;
            margin-bottom: 6px;
        }

        .wl-feature-desc {
            font-size: 13px;
            line-height: 1.6;
            color: #64748b;
        }

        /* ── Footer ──────────────────────────────────────────── */
        .wl-footer {
            position: relative;
            z-index: 1;
            max-width: 1120px;
            margin: 0 auto;
            padding: 20px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-top: 1px solid rgba(226, 232, 240, 0.5);
            font-size: 11.5px;
            color: #94a3b8;
        }

        .wl-footer-tech {
            font-family: 'JetBrains Mono', 'SF Mono', 'Fira Code', monospace;
            display: flex;
            gap: 16px;
        }

        /* ── Animations ──────────────────────────────────────── */
        @keyframes wlFadeUp {
            from {
                opacity: 0;
                transform: translateY(16px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* ── Responsive ──────────────────────────────────────── */
        @media (max-width: 768px) {
            .wl-features {
                grid-template-columns: 1fr;
            }

            .wl-hero {
                padding: 40px 20px 30px;
            }

            .wl-hero-actions {
                flex-direction: column;
            }

            .wl-footer {
                flex-direction: column;
                gap: 8px;
                text-align: center;
            }
        }
    </style>
</head>

<body>
    <!-- Header -->
    <header class="wl-header">
        <a href="/" class="wl-brand">
            <!-- <img src="{{ asset('/images/logo.png') }}" alt="BloomFem"> -->
            <div class="wl-brand-text">BloomFem</div>
        </a>
        <nav class="wl-header-nav">
            @if (Route::has('login'))
                @auth
                    <a href="{{ url('/admin') }}" class="wl-btn-primary">Buka Dasbor</a>
                @else
                    <a href="{{ url('/admin/login') }}" class="wl-btn-primary">Masuk Admin</a>
                @endauth
            @endif
        </nav>
    </header>

    <!-- Hero -->
    <main class="wl-hero">
        <div class="wl-hero-inner">
            <div class="wl-eyebrow">Portal Administrasi</div>
            <h1 class="wl-hero-title">
                Kelola Layanan<br><span>Kesehatan Edukasi</span>
            </h1>
            <p class="wl-hero-desc">
                Sistem dasbor terpusat untuk memoderasi forum komunitas, meninjau laporan, dan menganalisis statistik
                kemajuan kuis serta tingkat pembaca modul.
            </p>
            <div class="wl-hero-actions">
                @auth
                    <a href="{{ url('/admin') }}" class="wl-cta-main">Masuk Dasbor Panel</a>
                @else
                    <a href="{{ url('/admin/login') }}" class="wl-cta-main">Autentikasi Sekarang</a>
                @endauth
                <a href="https://github.com/reeeyyyyyyyyyyyyyyy/MobileApps-HealthEducation" target="_blank"
                    class="wl-cta-secondary">
                    Repositori
                    <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round"
                            d="M4.5 12h15m0 0l-6.75-6.75M19.5 12l-6.75 6.75" />
                    </svg>
                </a>
            </div>
        </div>
    </main>

    <!-- Features -->
    <section class="wl-features">
        <div class="wl-feature-card">
            <div class="wl-feature-icon" style="background: rgba(124, 58, 237, 0.08); color: #7c3aed;">
                <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round"
                        d="M12 6.042A8.967 8.967 0 006 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 016 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 016-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0018 18a8.967 8.967 0 00-6 2.292m0-14.25v14.25" />
                </svg>
            </div>
            <div class="wl-feature-title">Manajemen Modul</div>
            <p class="wl-feature-desc">Kelola konten edukasi kesehatan reproduksi dengan editor lengkap, kategorisasi,
                dan pelacakan jumlah pembaca.</p>
        </div>
        <div class="wl-feature-card">
            <div class="wl-feature-icon" style="background: rgba(16, 185, 129, 0.08); color: #059669;">
                <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round"
                        d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9 5.25h.008v.008H12v-.008z" />
                </svg>
            </div>
            <div class="wl-feature-title">Kuis Interaktif</div>
            <p class="wl-feature-desc">Buat kuis evaluasi pemahaman dengan soal pilihan ganda, sistem penilaian
                otomatis, dan hadiah XP untuk pengguna.</p>
        </div>
        <div class="wl-feature-card">
            <div class="wl-feature-icon" style="background: rgba(244, 63, 94, 0.08); color: #e11d48;">
                <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round"
                        d="M3 3v1.5M3 21v-6m0 0l2.77-.693a9 9 0 016.208.682l.108.054a9 9 0 006.086.71l3.114-.732a48.524 48.524 0 01-.005-10.499l-3.11.732a9 9 0 01-6.085-.711l-.108-.054a9 9 0 00-6.208-.682L3 4.5M3 15V4.5" />
                </svg>
            </div>
            <div class="wl-feature-title">Moderasi Laporan</div>
            <p class="wl-feature-desc">Tinjau dan kelola laporan konten dari forum komunitas dengan aksi moderasi cepat
                serta sistem ekspor data.</p>
        </div>
    </section>

    <!-- Footer -->
    <footer class="wl-footer">
        <div>&copy; {{ date('Y') }} BloomFem Project. Seluruh hak cipta dilindungi.</div>
        <div class="wl-footer-tech">
            <span>Laravel v{{ app()->version() }}</span>
            <span>PHP v{{ PHP_VERSION }}</span>
        </div>
    </footer>

    <!-- Goey Toast JS -->
    <script src="{{ asset('js/goey-toast.js') }}"></script>

    @if(session('success'))
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                if (window.goeyToast) window.goeyToast.success("{{ session('success') }}");
            });
        </script>
    @endif
    @if(session('error'))
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                if (window.goeyToast) window.goeyToast.error("{{ session('error') }}");
            });
        </script>
    @endif
</body>

</html>