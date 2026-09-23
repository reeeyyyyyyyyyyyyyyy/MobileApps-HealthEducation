<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RiskOption extends Model
{
    protected $table = 'risk_options';
    public $timestamps = false;

    protected $fillable = [
        'question_id',
        'option_text',
        'score',
        'option_order',
    ];

    protected $casts = [
        'score' => 'integer',
        'option_order' => 'integer',
    ];

    public function question(): BelongsTo
    {
        return $this->belongsTo(RiskQuestion::class, 'question_id', 'id');
    }
}
