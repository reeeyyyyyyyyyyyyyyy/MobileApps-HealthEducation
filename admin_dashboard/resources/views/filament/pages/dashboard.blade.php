<link rel="stylesheet" href="{{ asset('css/goey-toast.css') }}">
<script src="{{ asset('js/goey-toast.js') }}"></script>

<x-filament-panels::page>
    <div class="space-y-6">
        <!-- Header Banner / Visi Desain Murni -->
        <div class="relative overflow-hidden rounded-xl border border-zinc-200 bg-white p-6 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
            <div class="flex flex-col gap-1">
                <h1 class="text-xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
                    Dasbor Administrasi
                </h1>
                <p class="text-sm text-zinc-500 dark:text-zinc-400">
                    Pemantauan terpusat untuk data pengguna, performa modul edukasi, dan penanganan moderasi laporan konten.
                </p>
            </div>
        </div>

        <!-- Section 1: Overview Stats -->
        <div>
            @livewire(\App\Filament\Widgets\StatsOverview::class)
        </div>

        <!-- Section 2: Charts Grid -->
        <div class="grid grid-cols-1 gap-6 lg:grid-cols-2">
            <!-- Popular Modules Chart Box -->
            <div class="rounded-xl border border-zinc-200 bg-white p-6 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
                @livewire(\App\Filament\Widgets\PopularModulesChart::class)
            </div>

            <!-- Quiz Pass Ratio Chart Box -->
            <div class="rounded-xl border border-zinc-200 bg-white p-6 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
                @livewire(\App\Filament\Widgets\QuizPassRatioChart::class)
            </div>
        </div>
    </div>
</x-filament-panels::page>

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
