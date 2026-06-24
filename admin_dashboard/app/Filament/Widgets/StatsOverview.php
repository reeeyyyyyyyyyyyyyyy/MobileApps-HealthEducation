<?php

namespace App\Filament\Widgets;

use App\Models\User;
use App\Models\Post;
use App\Models\Report;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        $reportCount = Report::count();

        return [
            Stat::make('Total Pengguna', User::count())
                ->description('Total pengguna terdaftar')
                ->descriptionIcon('heroicon-m-users')
                ->color('success'),
            Stat::make('Total Postingan', Post::count())
                ->description('Total postingan di forum')
                ->descriptionIcon('heroicon-m-chat-bubble-left-ellipsis')
                ->color('info'),
            Stat::make('Total Laporan', $reportCount)
                ->description($reportCount > 0 ? 'Ada laporan yang perlu ditinjau' : 'Semua aman')
                ->descriptionIcon('heroicon-m-exclamation-triangle')
                ->color($reportCount > 0 ? 'danger' : 'success'),
        ];
    }
}
