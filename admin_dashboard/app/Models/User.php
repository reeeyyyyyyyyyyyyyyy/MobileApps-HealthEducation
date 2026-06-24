<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class User extends Model
{
    use HasUuids;

    protected $table = 'profiles';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $guarded = [];

    /**
     * Accessor to return full_name when name is accessed.
     */
    public function getNameAttribute(): ?string
    {
        return $this->full_name;
    }

    public function posts()
    {
        return $this->hasMany(Post::class, 'user_id');
    }

    public function comments()
    {
        return $this->hasMany(Comment::class, 'user_id');
    }

    public function reports()
    {
        return $this->hasMany(Report::class, 'reporter_id');
    }

    public function userQuizzes()
    {
        return $this->hasMany(UserQuiz::class, 'user_id');
    }
}
