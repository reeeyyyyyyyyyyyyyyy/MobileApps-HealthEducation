<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DailyHabit extends Model
{
    protected $table = 'daily_habits';
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'log_date',
        'water_intake',
        'no_hold_urine',
        'genital_hygiene',
        'physical_activity',
        'habit_score',
        'created_at',
    ];

    protected $casts = [
        'water_intake' => 'integer',
        'no_hold_urine' => 'boolean',
        'physical_activity' => 'integer',
        'habit_score' => 'integer',
        'created_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(Profile::class, 'user_id', 'id');
    }
}
