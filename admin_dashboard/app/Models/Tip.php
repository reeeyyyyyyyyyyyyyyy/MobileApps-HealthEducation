<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Tip extends Model
{
    protected $table = 'daily_tips';

    protected $fillable = ['title', 'content', 'category'];

    public $timestamps = false;
}
