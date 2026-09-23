<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Profile;
use App\Models\DailyHabit;
use App\Models\RiskResult;
use App\Models\EducationMaterial;
use App\Models\SurveyResponse;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    public function index(): Response
    {
        $totalRespondents = Profile::count();
        $completedPretest = Profile::where('has_completed_pretest', true)->count();
        $completedPosttest = Profile::where('has_completed_posttest', true)->count();
        $totalMaterials = EducationMaterial::where('published', 1)->count();

        // Risk distribution
        $riskDistribution = [
            'rendah' => RiskResult::where('risk_level', 'rendah')->count(),
            'sedang' => RiskResult::where('risk_level', 'sedang')->count(),
            'tinggi' => RiskResult::where('risk_level', 'tinggi')->count(),
        ];

        // School distribution
        $schoolDistribution = Profile::select('school', DB::raw('count(*) as count'))
            ->whereNotNull('school')
            ->where('school', '!=', '')
            ->groupBy('school')
            ->orderBy('count', 'desc')
            ->limit(10)
            ->get();

        // Average Daily Habits (last 7 days)
        $avgHabits = DailyHabit::select(
            DB::raw('ROUND(AVG(water_intake), 1) as avg_water'),
            DB::raw('ROUND(AVG(CASE WHEN no_hold_urine THEN 1 ELSE 0 END) * 100, 1) as pct_no_hold'),
            DB::raw('ROUND(AVG(physical_activity), 1) as avg_activity'),
            DB::raw('ROUND(AVG(habit_score), 1) as avg_score')
        )->first();

        // Recent respondents
        $recentRespondents = Profile::orderBy('created_at', 'desc')
            ->limit(6)
            ->get();

        // Pre vs Post Score comparison for students who finished both
        $pretestScores = DB::table('survey_responses as sr')
            ->join('survey_options as so', 'sr.selected_option_id', '=', 'so.id')
            ->join('survey_instruments as si', 'sr.instrument_id', '=', 'si.id')
            ->where('sr.type', 'pretest')
            ->select('si.variable', DB::raw('ROUND(AVG(so.score), 2) as avg_score'))
            ->groupBy('si.variable')
            ->get()
            ->keyBy('variable');

        $posttestScores = DB::table('survey_responses as sr')
            ->join('survey_options as so', 'sr.selected_option_id', '=', 'so.id')
            ->join('survey_instruments as si', 'sr.instrument_id', '=', 'si.id')
            ->where('sr.type', 'posttest')
            ->select('si.variable', DB::raw('ROUND(AVG(so.score), 2) as avg_score'))
            ->groupBy('si.variable')
            ->get()
            ->keyBy('variable');

        $comparisonData = [
            [
                'variable' => 'Pengetahuan',
                'pretest' => (float) ($pretestScores['pengetahuan']->avg_score ?? 0),
                'posttest' => (float) ($posttestScores['pengetahuan']->avg_score ?? 0),
            ],
            [
                'variable' => 'Sikap',
                'pretest' => (float) ($pretestScores['sikap']->avg_score ?? 0),
                'posttest' => (float) ($posttestScores['sikap']->avg_score ?? 0),
            ],
            [
                'variable' => 'Perilaku',
                'pretest' => (float) ($pretestScores['perilaku']->avg_score ?? 0),
                'posttest' => (float) ($posttestScores['perilaku']->avg_score ?? 0),
            ],
        ];

        return Inertia::render('Admin/Dashboard', [
            'stats' => [
                'totalRespondents' => $totalRespondents,
                'completedPretest' => $completedPretest,
                'completedPosttest' => $completedPosttest,
                'totalMaterials' => $totalMaterials,
            ],
            'riskDistribution' => $riskDistribution,
            'schoolDistribution' => $schoolDistribution,
            'avgHabits' => $avgHabits,
            'recentRespondents' => $recentRespondents,
            'comparisonData' => $comparisonData,
        ]);
    }
}
