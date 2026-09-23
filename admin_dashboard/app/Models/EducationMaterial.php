<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EducationMaterial extends Model
{
    protected $table = 'education_materials';

    protected $fillable = [
        'title',
        'category',
        'content',
        'video_url',
        'thumbnail_url',
        'hbm_component',
        'view_count',
        'published',
        'sort_order',
    ];

    protected $casts = [
        'published' => 'integer',
        'view_count' => 'integer',
        'sort_order' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}
