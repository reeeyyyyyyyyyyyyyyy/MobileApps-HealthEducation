<?php

namespace App\Filament\Widgets;

use App\Models\Module;
use Filament\Widgets\ChartWidget;

class PopularModulesChart extends ChartWidget
{
    protected static ?string $heading = 'Modul Paling Sering Dibaca';

    protected function getData(): array
    {
        $modules = Module::orderBy('view_count', 'desc')->take(5)->get();

        return [
            'datasets' => [
                [
                    'label' => 'Jumlah Pembaca',
                    'data' => $modules->pluck('view_count')->toArray(),
                    'backgroundColor' => [
                        'rgba(54, 162, 235, 0.2)',
                    ],
                    'borderColor' => [
                        'rgba(54, 162, 235, 1)',
                    ],
                    'borderWidth' => 1,
                ],
            ],
            'labels' => $modules->pluck('title')->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }
}
