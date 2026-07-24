<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Atomcoder\LaravelReorderable\Traits\HasSortOrder;

class LearningPath extends Model
{
    use HasSortOrder;

    protected $table = 'learning_paths';

    public $timestamps = false;

    protected $fillable = [
        'title',
        'description',
        'icon',
        'sort_order',
    ];

    public function modules()
    {
        return $this->belongsToMany(Module::class, 'learning_path_modules', 'path_id', 'module_id')
                    ->withPivot('sort_order')
                    ->orderBy('learning_path_modules.sort_order');
    }
}
