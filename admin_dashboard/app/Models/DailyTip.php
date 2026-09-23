<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DailyTip extends Model
{
    protected $table = 'daily_tips';
    public $timestamps = false;

    protected $fillable = [
        'title',
        'content',
        'category',
        'is_active',
        'created_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'created_at' => 'datetime',
    ];
}
