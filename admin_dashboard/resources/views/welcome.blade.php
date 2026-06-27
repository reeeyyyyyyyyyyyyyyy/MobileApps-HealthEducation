<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>BloomFem Admin Portal</title>
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['"Plus Jakarta Sans"', 'sans-serif'],
                        mono: ['"JetBrains Mono"', 'monospace'],
                    }
                }
            }
        }
    </script>
    <!-- Gooey Toast -->
    <link rel="stylesheet" href="{{ asset('css/goey-toast.css') }}">
    <script src="{{ asset('js/goey-toast.js') }}"></script>
</head>
<body class="bg-zinc-50 dark:bg-zinc-950 text-zinc-900 dark:text-zinc-50 antialiased font-sans min-h-screen flex flex-col justify-between selection:bg-violet-500 selection:text-white">
    <!-- Top Nav -->
    <header class="w-full max-w-7xl mx-auto px-6 py-6 flex items-center justify-between border-b border-zinc-200/50 dark:border-zinc-800/50">
        <div class="flex items-center gap-3">
            <div class="w-8 h-8 rounded-lg bg-violet-600 flex items-center justify-center text-white font-extrabold text-lg tracking-tighter">B</div>
            <span class="font-bold tracking-tight text-lg text-zinc-900 dark:text-white">BloomFem</span>
        </div>
        <nav class="flex items-center gap-4">
            @if (Route::has('login'))
                @auth
                    <a href="{{ url('/admin') }}" class="px-4 py-2 text-sm font-semibold text-white bg-violet-600 hover:bg-violet-700 active:scale-95 transition-all rounded-lg shadow-sm">
                        Buka Dasbor
                    </a>
                @else
                    <a href="{{ url('/admin/login') }}" class="px-4 py-2 text-sm font-semibold text-zinc-900 dark:text-zinc-100 hover:bg-zinc-200/50 dark:hover:bg-zinc-800/50 rounded-lg transition-colors">
                        Masuk Admin
                    </a>
                @endauth
            @endif
        </nav>
    </header>

    <!-- Main Content Area -->
    <main class="w-full max-w-7xl mx-auto px-6 py-20 flex-grow flex flex-col justify-center">
        <div class="max-w-3xl">
            <!-- Eyebrow -->
            <span class="font-mono text-xs font-semibold tracking-widest text-violet-600 dark:text-violet-400 uppercase">BLOOMFEM PORTAL ADMINISTRASI</span>
            
            <h1 class="mt-6 text-4xl sm:text-6xl font-extrabold tracking-tight leading-none text-zinc-900 dark:text-white">
                Kelola Layanan<br>Kesehatan Edukasi
            </h1>
            
            <p class="mt-6 text-lg text-zinc-600 dark:text-zinc-400 leading-relaxed max-w-xl">
                Sistem dasbor administrasi terpusat untuk memoderasi forum komunitas, meninjau laporan, serta menganalisis statistik kemajuan kuis dan tingkat pembaca modul.
            </p>

            <div class="mt-10 flex flex-wrap items-center gap-4">
                @auth
                    <a href="{{ url('/admin') }}" class="px-6 py-3 font-semibold text-white bg-violet-600 hover:bg-violet-700 active:scale-95 transition-all rounded-lg shadow-md">
                        Masuk Dasbor Panel
                    </a>
                @else
                    <a href="{{ url('/admin/login') }}" class="px-6 py-3 font-semibold text-white bg-violet-600 hover:bg-violet-700 active:scale-95 transition-all rounded-lg shadow-md">
                        Autentikasi Sekarang
                    </a>
                @endauth
                <a href="https://github.com/reeeyyyyyyyyyyyyyyy/MobileApps-HealthEducation" target="_blank" class="px-6 py-3 font-semibold text-zinc-700 dark:text-zinc-300 hover:text-zinc-900 dark:hover:text-white border border-zinc-300 dark:border-zinc-700 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-lg transition-colors">
                    Dokumentasi Repositori
                </a>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="w-full max-w-7xl mx-auto px-6 py-8 border-t border-zinc-200/50 dark:border-zinc-800/50 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-zinc-500 dark:text-zinc-400">
        <div>
            &copy; {{ date('Y') }} BloomFem Project. Seluruh hak cipta dilindungi.
        </div>
        <div class="flex items-center gap-4 font-mono">
            <span>Laravel v{{ app()->version() }}</span>
            <span>PHP v{{ PHP_VERSION }}</span>
        </div>
    </footer>

    @if(session('success'))
        <script>
            window.addEventListener('load', function() {
                window.goeyToast.success("{{ session('success') }}");
            });
        </script>
    @endif
    @if(session('error'))
        <script>
            window.addEventListener('load', function() {
                window.goeyToast.error("{{ session('error') }}");
            });
        </script>
    @endif
</body>
</html>
