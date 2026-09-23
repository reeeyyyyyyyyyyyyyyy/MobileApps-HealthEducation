<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Profile extends Model
{
    protected $table = 'profiles';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'full_name',
        'age',
        'school',
        'class',
        'phone',
        'has_completed_pretest',
        'has_completed_posttest',
        'pretest_completed_at',
        'posttest_completed_at',
        'created_at',
    ];

    protected $casts = [
        'has_completed_pretest' => 'boolean',
        'has_completed_posttest' => 'boolean',
        'pretest_completed_at' => 'datetime',
        'posttest_completed_at' => 'datetime',
        'created_at' => 'datetime',
    ];

    public function dailyHabits(): HasMany
    {
        return $this->hasMany(DailyHabit::class, 'user_id', 'id')->orderBy('log_date', 'desc');
    }

    public function riskResults(): HasMany
    {
        return $this->hasMany(RiskResult::class, 'user_id', 'id')->orderBy('created_at', 'desc');
    }

    public function surveyResponses(): HasMany
    {
        return $this->hasMany(SurveyResponse::class, 'user_id', 'id');
    }
}
