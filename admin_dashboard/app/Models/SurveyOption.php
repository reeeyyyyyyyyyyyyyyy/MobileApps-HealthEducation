<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SurveyOption extends Model
{
    protected $table = 'survey_options';
    public $timestamps = false;

    protected $fillable = [
        'instrument_id',
        'option_text',
        'score',
        'option_order',
    ];

    protected $casts = [
        'score' => 'integer',
        'option_order' => 'integer',
    ];

    public function instrument(): BelongsTo
    {
        return $this->belongsTo(SurveyInstrument::class, 'instrument_id', 'id');
    }
}
