<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RiskResult extends Model
{
    protected $table = 'risk_results';
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'total_score',
        'risk_level',
        'answers',
        'created_at',
    ];

    protected $casts = [
        'total_score' => 'integer',
        'answers' => 'array',
        'created_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(Profile::class, 'user_id', 'id');
    }
}
