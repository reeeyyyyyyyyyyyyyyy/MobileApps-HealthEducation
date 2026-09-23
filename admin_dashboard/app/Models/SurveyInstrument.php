<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SurveyInstrument extends Model
{
    protected $table = 'survey_instruments';
    public $timestamps = false;

    protected $fillable = [
        'type',
        'variable',
        'question_text',
        'question_order',
        'is_active',
        'created_at',
    ];

    protected $casts = [
        'question_order' => 'integer',
        'is_active' => 'boolean',
        'created_at' => 'datetime',
    ];

    public function options(): HasMany
    {
        return $this->hasMany(SurveyOption::class, 'instrument_id', 'id')->orderBy('option_order', 'asc');
    }

    public function responses(): HasMany
    {
        return $this->hasMany(SurveyResponse::class, 'instrument_id', 'id');
    }
}
