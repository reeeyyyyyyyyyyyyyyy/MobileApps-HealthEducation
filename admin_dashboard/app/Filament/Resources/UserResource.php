<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-users';

    protected static ?string $navigationLabel = 'Progres Pengguna';

    protected static ?string $pluralLabel = 'Progres Pengguna';

    protected static ?string $modelLabel = 'Progres Pengguna';

    public static function canCreate(): bool
    {
        return false;
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('username')
                    ->disabled(),
                Forms\Components\TextInput::make('full_name')
                    ->disabled(),
                Forms\Components\TextInput::make('level')
                    ->disabled(),
                Forms\Components\TextInput::make('total_xp')
                    ->disabled(),
                Forms\Components\TextInput::make('modul_selesai')
                    ->disabled(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('username')
                    ->label('Username')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('full_name')
                    ->label('Nama Lengkap')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('level')
                    ->label('Level')
                    ->sortable(),
                Tables\Columns\TextColumn::make('total_xp')
                    ->label('Total XP')
                    ->sortable(),
                Tables\Columns\TextColumn::make('modul_selesai')
                    ->label('Jumlah Modul Selesai')
                    ->sortable(),
                Tables\Columns\TextColumn::make('passed_quizzes_count')
                    ->label('Jumlah Kuis Lulus')
                    ->getStateUsing(fn (User $record): int => $record->userQuizzes()->where('status', 'passed')->count()),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
            ])
            ->headerActions([
                Tables\Actions\ExportAction::make()
                    ->exporter(\App\Filament\Exports\UserExporter::class),
            ])
            ->bulkActions([
                // None
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ManageUsers::route('/'),
        ];
    }
}
