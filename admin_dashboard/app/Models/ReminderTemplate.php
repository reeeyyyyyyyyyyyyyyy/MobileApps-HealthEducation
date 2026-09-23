<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ReminderTemplate extends Model
{
    protected $table = 'reminder_templates';
    public $timestamps = false;

    protected $fillable = [
        'title',
        'description',
        'default_time',
        'icon_name',
        'is_active',
        'sort_order',
        'created_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'sort_order' => 'integer',
        'created_at' => 'datetime',
    ];
}
