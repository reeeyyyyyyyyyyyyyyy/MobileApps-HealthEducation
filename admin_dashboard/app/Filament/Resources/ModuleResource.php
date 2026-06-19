<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ModuleResource\Pages;
use App\Filament\Resources\ModuleResource\RelationManagers;
use App\Models\Module;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class ModuleResource extends Resource
{
    protected static ?string $model = Module::class;

    protected static ?string $navigationIcon = 'heroicon-o-book-open';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informasi Modul')
                    ->description('Masukkan detail informasi artikel edukasi.')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label('Judul Modul')
                            ->required()
                            ->maxLength(255)
                            ->columnSpan('full'),
                        
                        Forms\Components\Select::make('category')
                            ->label('Kategori')
                            ->options([
                                'Pengetahuan' => 'Pengetahuan',
                                'Sikap Positif' => 'Sikap Positif',
                                'Perilaku Sehat' => 'Perilaku Sehat',
                            ])
                            ->required(),
                        
                        Forms\Components\TextInput::make('duration')
                            ->label('Durasi Baca (e.g. "5 menit" atau "5")')
                            ->required()
                            ->maxLength(50),

                        Forms\Components\Select::make('icon_name')
                            ->label('Ikon Modul')
                            ->options([
                                'psychology_rounded' => 'Psychology (Mitos/Fakta)',
                                'volunteer_activism_rounded' => 'Volunteer Activism (Kelola Nyeri)',
                                'favorite_rounded' => 'Favorite (Bangga Tubuhmu)',
                                'healing_rounded' => 'Healing (Kesehatan)',
                                'clean_hands_rounded' => 'Clean Hands (Kebersihan)',
                                'restaurant_rounded' => 'Restaurant (Nutrisi)',
                                'checkroom_rounded' => 'Checkroom (Pembalut)',
                                'self_improvement_rounded' => 'Self Improvement (PMS)',
                                'water_drop_rounded' => 'Water Drop (Menstruasi)',
                            ])
                            ->required()
                            ->default('water_drop_rounded'),

                        Forms\Components\TextInput::make('video_url')
                            ->label('Link Video Youtube (Optional)')
                            ->url()
                            ->maxLength(255),

                        Forms\Components\RichEditor::make('content')
                            ->label('Konten Edukasi Lengkap')
                            ->required()
                            ->columnSpan('full')
                            ->toolbarButtons([
                                'bold',
                                'italic',
                                'bulletList',
                                'orderedList',
                                'undo',
                                'redo',
                            ]),

                        Forms\Components\TextInput::make('view_count')
                            ->label('Jumlah Dilihat')
                            ->numeric()
                            ->default(0)
                            ->disabled()
                            ->dehydrated(false),
                    ])
                    ->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('Judul')
                    ->searchable()
                    ->sortable()
                    ->wrap(),
                
                Tables\Columns\TextColumn::make('category')
                    ->label('Kategori')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'Pengetahuan' => 'info',
                        'Sikap Positif' => 'success',
                        'Perilaku Sehat' => 'warning',
                        default => 'gray',
                    })
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('duration')
                    ->label('Durasi')
                    ->sortable(),

                Tables\Columns\TextColumn::make('view_count')
                    ->label('Dilihat')
                    ->numeric()
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Dibuat Pada')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('category')
                    ->label('Kategori')
                    ->options([
                        'Pengetahuan' => 'Pengetahuan',
                        'Sikap Positif' => 'Sikap Positif',
                        'Perilaku Sehat' => 'Perilaku Sehat',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListModules::route('/'),
            'create' => Pages\CreateModule::route('/create'),
            'edit' => Pages\EditModule::route('/{record}/edit'),
        ];
    }
}
