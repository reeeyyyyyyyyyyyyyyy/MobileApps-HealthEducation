<x-filament-panels::page>
    <style>
        /* Dashboard-specific styles */
        .bf-dash-greeting {
            font-size: 26px;
            font-weight: 800;
            letter-spacing: -0.03em;
            color: #0f172a;
            line-height: 1.2;
        }
        .bf-dash-subtitle {
            font-size: 14px;
            color: #64748b;
            margin-top: 4px;
            font-weight: 500;
        }
        .bf-dash-card {
            background: #ffffff;
            border: 1px solid rgba(226, 232, 240, 0.7);
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
            transition: box-shadow 0.2s ease, border-color 0.2s ease, transform 0.2s ease;
        }
        .bf-dash-card:hover {
            box-shadow: 0 4px 16px -2px rgba(15, 23, 42, 0.06), 0 1px 3px rgba(15, 23, 42, 0.03);
            border-color: rgba(139, 92, 246, 0.2);
        }
        .bf-dash-quick-link {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 16px 20px;
            background: #ffffff;
            border: 1px solid rgba(226, 232, 240, 0.7);
            border-radius: 14px;
            text-decoration: none;
            color: #334155;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.2s ease;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
        }
        .bf-dash-quick-link:hover {
            border-color: rgba(139, 92, 246, 0.3);
            box-shadow: 0 8px 24px -4px rgba(124, 58, 237, 0.1);
            transform: translateY(-2px);
            color: #7c3aed;
        }
        .bf-dash-quick-icon {
            width: 40px;
            height: 40px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .bf-dash-section-label {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: #94a3b8;
            margin-bottom: 12px;
        }
        .bf-dash-animate {
            animation: bfDashIn 0.4s ease-out both;
        }
        .bf-dash-animate-delay-1 { animation-delay: 0.05s; }
        .bf-dash-animate-delay-2 { animation-delay: 0.1s; }
        .bf-dash-animate-delay-3 { animation-delay: 0.15s; }
        .bf-dash-animate-delay-4 { animation-delay: 0.2s; }

        @keyframes bfDashIn {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>

    <div style="display: flex; flex-direction: column; gap: 24px;">

        {{-- Header Greeting --}}
        <div class="bf-dash-animate" style="display: flex; align-items: center; justify-content: space-between;">
            <div>
                @php
                    $hour = (int) now()->format('H');
                    if ($hour >= 5 && $hour < 12) {
                        $greeting = 'Selamat Pagi';
                    } elseif ($hour >= 12 && $hour < 17) {
                        $greeting = 'Selamat Siang';
                    } elseif ($hour >= 17 && $hour < 21) {
                        $greeting = 'Selamat Sore';
                    } else {
                        $greeting = 'Selamat Malam';
                    }
                @endphp
                <p class="bf-dash-greeting">{{ $greeting }}, {{ auth()->user()->name ?? 'Admin' }}</p>
                <p class="bf-dash-subtitle">Ringkasan aktivitas dan statistik platform BloomFem.</p>
            </div>
            <div style="font-size: 12px; color: #94a3b8; font-weight: 600; font-family: 'JetBrains Mono', monospace;">
                {{ now()->translatedFormat('l, d F Y') }}
            </div>
        </div>

        {{-- Stats Overview --}}
        <div class="bf-dash-animate bf-dash-animate-delay-1">
            <div class="bf-dash-section-label">Ikhtisar</div>
            @livewire(\App\Filament\Widgets\StatsOverview::class)
        </div>

        {{-- Charts Grid --}}
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;" class="bf-dash-animate bf-dash-animate-delay-2">
            <div class="bf-dash-card">
                <div class="bf-dash-section-label">Modul Terpopuler</div>
                @livewire(\App\Filament\Widgets\PopularModulesChart::class)
            </div>
            <div class="bf-dash-card">
                <div class="bf-dash-section-label">Rasio Kelulusan Kuis</div>
                @livewire(\App\Filament\Widgets\QuizPassRatioChart::class)
            </div>
        </div>

        {{-- Quick Actions --}}
        <div class="bf-dash-animate bf-dash-animate-delay-3">
            <div class="bf-dash-section-label">Aksi Cepat</div>
            <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px;">
                <a href="{{ url('/admin/modules') }}" class="bf-dash-quick-link">
                    <div class="bf-dash-quick-icon" style="background: rgba(139, 92, 246, 0.08); color: #7c3aed;">
                        <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6.042A8.967 8.967 0 006 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 016 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 016-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0018 18a8.967 8.967 0 00-6 2.292m0-14.25v14.25"/></svg>
                    </div>
                    <span>Kelola Modul</span>
                </a>
                <a href="{{ url('/admin/quizzes') }}" class="bf-dash-quick-link">
                    <div class="bf-dash-quick-icon" style="background: rgba(16, 185, 129, 0.08); color: #059669;">
                        <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9 5.25h.008v.008H12v-.008z"/></svg>
                    </div>
                    <span>Kelola Kuis</span>
                </a>
                <a href="{{ url('/admin/reports') }}" class="bf-dash-quick-link">
                    <div class="bf-dash-quick-icon" style="background: rgba(244, 63, 94, 0.08); color: #e11d48;">
                        <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z"/></svg>
                    </div>
                    <span>Tinjau Laporan</span>
                </a>
                <a href="{{ url('/admin/users') }}" class="bf-dash-quick-link">
                    <div class="bf-dash-quick-icon" style="background: rgba(37, 99, 235, 0.08); color: #2563eb;">
                        <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z"/></svg>
                    </div>
                    <span>Progres Pengguna</span>
                </a>
            </div>
        </div>

        {{-- Footer Info --}}
        <div class="bf-dash-animate bf-dash-animate-delay-4" style="text-align: center; padding: 16px 0 4px; font-size: 11.5px; color: #94a3b8; font-weight: 500;">
            BloomFem Admin Portal &mdash; Laravel v{{ app()->version() }}
        </div>
    </div>
</x-filament-panels::page>
