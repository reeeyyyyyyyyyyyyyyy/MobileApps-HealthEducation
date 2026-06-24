<?php

namespace App\Filament\Exports;

use App\Models\User;
use Filament\Actions\Exports\ExportColumn;
use Filament\Actions\Exports\Exporter;
use Filament\Actions\Exports\Models\Export;

class UserExporter extends Exporter
{
    protected static ?string $model = User::class;

    public static function getColumns(): array
    {
        return [
            ExportColumn::make('id')
                ->label('ID Pengguna'),
            ExportColumn::make('username')
                ->label('Username'),
            ExportColumn::make('full_name')
                ->label('Nama Lengkap'),
            ExportColumn::make('level')
                ->label('Level'),
            ExportColumn::make('total_xp')
                ->label('Total XP'),
            ExportColumn::make('modul_selesai')
                ->label('Jumlah Modul Selesai'),
            ExportColumn::make('passed_quizzes_count')
                ->label('Jumlah Kuis Lulus')
                ->state(fn (User $record): int => $record->userQuizzes()->where('status', 'passed')->count()),
        ];
    }

    public static function getCompletedNotificationBody(Export $export): string
    {
        $body = 'Your user export has completed and ' . number_format($export->successful_rows) . ' ' . str('row')->plural($export->successful_rows) . ' exported.';

        if ($failedRowsCount = $export->getFailedRowsCount()) {
            $body .= ' ' . number_format($failedRowsCount) . ' ' . str('row')->plural($failedRowsCount) . ' failed to export.';
        }

        return $body;
    }
}
