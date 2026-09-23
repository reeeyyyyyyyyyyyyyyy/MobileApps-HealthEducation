<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class RiskQuestion extends Model
{
    protected $table = 'risk_questions';
    public $timestamps = false;

    protected $fillable = [
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
        return $this->hasMany(RiskOption::class, 'question_id', 'id')->orderBy('option_order', 'asc');
    }
}
