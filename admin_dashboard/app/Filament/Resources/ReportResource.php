<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ReportResource\Pages;
use App\Models\Report;
use App\Models\Post;
use App\Models\Comment;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;

class ReportResource extends Resource
{
    protected static ?string $model = Report::class;

    protected static ?string $navigationIcon = 'heroicon-o-exclamation-triangle';

    protected static ?string $navigationLabel = 'Laporan Moderasi';

    protected static ?string $pluralLabel = 'Laporan Moderasi';

    protected static ?string $modelLabel = 'Laporan';

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Placeholder::make('reporter_name')
                    ->label('Nama Pelapor')
                    ->content(fn (?Report $record) => $record?->reporter?->full_name ?? '-'),
                Forms\Components\Placeholder::make('reason')
                    ->label('Alasan Laporan')
                    ->content(fn (?Report $record) => $record?->reason ?? '-'),
                Forms\Components\Placeholder::make('content_type')
                    ->label('Jenis Konten')
                    ->content(fn (?Report $record) => $record?->post_id ? 'Post' : ($record?->comment_id ? 'Komentar' : '-')),
                Forms\Components\Placeholder::make('reported_content')
                    ->label('Konten yang Dilaporkan')
                    ->content(fn (?Report $record) => $record?->post?->content ?? $record?->comment?->content ?? '-')
                    ->columnSpanFull(),
                Forms\Components\Placeholder::make('created_at')
                    ->label('Tanggal Dilaporkan')
                    ->content(fn (?Report $record) => $record?->created_at?->format('d M Y H:i:s') ?? '-'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('reporter.name')
                    ->label('Nama Pelapor')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('reason')
                    ->label('Alasan')
                    ->searchable()
                    ->limit(50),
                Tables\Columns\TextColumn::make('type')
                    ->label('Jenis Konten')
                    ->getStateUsing(fn (Report $record) => $record->post_id ? 'Post' : ($record->comment_id ? 'Komentar' : '-')),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Tanggal Lapor')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\Action::make('hapus_konten')
                    ->label('Hapus Konten')
                    ->color('danger')
                    ->icon('heroicon-o-trash')
                    ->requiresConfirmation()
                    ->action(function (Report $record) {
                        if ($record->post_id) {
                            $post = Post::find($record->post_id);
                            if ($post) {
                                $post->delete();
                            }
                        } elseif ($record->comment_id) {
                            $comment = Comment::find($record->comment_id);
                            if ($comment) {
                                $comment->delete();
                            }
                        }

                        Notification::make()
                            ->title('Konten berhasil dihapus')
                            ->success()
                            ->send();
                    }),
            ])
            ->headerActions([
                Tables\Actions\ExportAction::make()
                    ->exporter(\App\Filament\Exports\ReportExporter::class),
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
            'index' => Pages\ListReports::route('/'),
            'view' => Pages\ViewReport::route('/{record}'),
        ];
    }
}
