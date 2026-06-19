<?php

namespace App\Filament\Resources;

use App\Filament\Resources\QuizResource\Pages;
use App\Filament\Resources\QuizResource\RelationManagers;
use App\Models\Quiz;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class QuizResource extends Resource
{
    protected static ?string $model = Quiz::class;

    protected static ?string $navigationIcon = 'heroicon-o-question-mark-circle';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informasi Kuis')
                    ->description('Masukkan detail informasi kuis.')
                    ->schema([
                        Forms\Components\Select::make('module_id')
                            ->relationship('module', 'title')
                            ->required()
                            ->label('Modul Terkait'),
                        
                        Forms\Components\TextInput::make('title')
                            ->required()
                            ->maxLength(255)
                            ->label('Judul Kuis'),
                        
                        Forms\Components\TextInput::make('xp_reward')
                            ->numeric()
                            ->default(100)
                            ->required()
                            ->label('Hadiah XP'),
                        
                        Forms\Components\Textarea::make('description')
                            ->label('Deskripsi Kuis')
                            ->columnSpanFull(),
                    ])
                    ->columns(3),

                Forms\Components\Section::make('Soal-Soal Kuis')
                    ->description('Tambahkan daftar pertanyaan untuk kuis ini.')
                    ->schema([
                        Forms\Components\Repeater::make('questions')
                            ->relationship('questions')
                            ->schema([
                                Forms\Components\Textarea::make('question_text')
                                    ->required()
                                    ->rows(2)
                                    ->label('Pertanyaan')
                                    ->columnSpan('full'),
                                
                                Forms\Components\Repeater::make('options')
                                    ->label('Pilihan Jawaban')
                                    ->simple(
                                        Forms\Components\TextInput::make('option_text')
                                            ->required()
                                            ->placeholder('Ketik opsi pilihan jawaban...')
                                    )
                                    ->minItems(2)
                                    ->maxItems(6)
                                    ->default(['', '', '', ''])
                                    ->columnSpan('full'),

                                Forms\Components\Select::make('correct_index')
                                    ->label('Index Jawaban Benar (0-indexed)')
                                    ->options([
                                        0 => 'Opsi ke-1 (Indeks 0)',
                                        1 => 'Opsi ke-2 (Indeks 1)',
                                        2 => 'Opsi ke-3 (Indeks 2)',
                                        3 => 'Opsi ke-4 (Indeks 3)',
                                        4 => 'Opsi ke-5 (Indeks 4)',
                                        5 => 'Opsi ke-6 (Indeks 5)',
                                    ])
                                    ->required(),

                                Forms\Components\TextInput::make('explanation')
                                    ->label('Penjelasan (Optional)')
                                    ->columnSpan('full'),
                            ])
                            ->columns(1)
                            ->collapsible()
                            ->itemLabel(fn (array $state): ?string => $state['question_text'] ?? 'Pertanyaan Baru')
                            ->defaultItems(0)
                    ])
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('Judul Kuis')
                    ->searchable()
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('module.title')
                    ->label('Modul Materi')
                    ->searchable()
                    ->sortable()
                    ->wrap(),

                Tables\Columns\TextColumn::make('xp_reward')
                    ->label('Hadiah XP')
                    ->sortable()
                    ->numeric(),

                Tables\Columns\TextColumn::make('questions_count')
                    ->label('Jumlah Soal')
                    ->counts('questions')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('module_id')
                    ->label('Berdasarkan Modul')
                    ->relationship('module', 'title'),
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
            'index' => Pages\ListQuizzes::route('/'),
            'create' => Pages\CreateQuiz::route('/create'),
            'edit' => Pages\EditQuiz::route('/{record}/edit'),
        ];
    }
}
