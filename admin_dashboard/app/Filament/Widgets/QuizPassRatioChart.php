<?php

namespace App\Filament\Widgets;

use App\Models\UserQuiz;
use Filament\Widgets\ChartWidget;

class QuizPassRatioChart extends ChartWidget
{
    protected static ?string $heading = 'Rasio Kelulusan Kuis';

    protected function getData(): array
    {
        $passedCount = UserQuiz::where('status', 'passed')->count();
        $failedCount = UserQuiz::where('status', 'failed')->count();

        return [
            'datasets' => [
                [
                    'label' => 'Rasio Kelulusan',
                    'data' => [$passedCount, $failedCount],
                    'backgroundColor' => [
                        '#10B981', // Hijau (Passed)
                        '#EF4444', // Merah (Failed)
                    ],
                ],
            ],
            'labels' => ['Lulus', 'Gagal'],
        ];
    }

    protected function getType(): string
    {
        return 'doughnut';
    }
}
