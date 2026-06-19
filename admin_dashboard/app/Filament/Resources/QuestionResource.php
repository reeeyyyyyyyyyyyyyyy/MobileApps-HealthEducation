<?php

namespace App\Filament\Resources;

use App\Filament\Resources\QuestionResource\Pages;
use App\Filament\Resources\QuestionResource\RelationManagers;
use App\Models\Question;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class QuestionResource extends Resource
{
    protected static ?string $model = Question::class;

    protected static ?string $navigationIcon = 'heroicon-o-list-bullet';

    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Detail Pertanyaan')
                    ->schema([
                        Forms\Components\Select::make('quiz_id')
                            ->relationship('quiz', 'title')
                            ->required()
                            ->label('Kuis Terkait'),
                        
                        Forms\Components\Textarea::make('question_text')
                            ->required()
                            ->rows(3)
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
                            ->label('Opsi Jawaban Benar')
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
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('quiz.title')
                    ->label('Kuis')
                    ->searchable()
                    ->sortable()
                    ->wrap(),
                
                Tables\Columns\TextColumn::make('question_text')
                    ->label('Pertanyaan')
                    ->searchable()
                    ->sortable()
                    ->limit(60)
                    ->wrap(),

                Tables\Columns\TextColumn::make('correct_index')
                    ->label('Indeks Benar')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('quiz_id')
                    ->label('Berdasarkan Kuis')
                    ->relationship('quiz', 'title'),
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
            'index' => Pages\ListQuestions::route('/'),
            'create' => Pages\CreateQuestion::route('/create'),
            'edit' => Pages\EditQuestion::route('/{record}/edit'),
        ];
    }
}
