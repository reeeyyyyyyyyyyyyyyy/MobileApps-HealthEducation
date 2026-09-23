<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SurveyResponse extends Model
{
    protected $table = 'survey_responses';
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'instrument_id',
        'selected_option_id',
        'type',
        'created_at',
    ];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(Profile::class, 'user_id', 'id');
    }

    public function instrument(): BelongsTo
    {
        return $this->belongsTo(SurveyInstrument::class, 'instrument_id', 'id');
    }

    public function selectedOption(): BelongsTo
    {
        return $this->belongsTo(SurveyOption::class, 'selected_option_id', 'id');
    }
}
