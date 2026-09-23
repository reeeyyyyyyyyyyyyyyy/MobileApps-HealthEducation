<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Profile;
use App\Models\DailyHabit;
use App\Models\RiskResult;
use App\Models\SurveyResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;
use Symfony\Component\HttpFoundation\StreamedResponse;

class RespondentController extends Controller
{
    public function index(Request $request): Response
    {
        $query = Profile::query();

        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('full_name', 'ilike', "%{$search}%")
                  ->orWhere('school', 'ilike', "%{$search}%")
                  ->orWhere('class', 'ilike', "%{$search}%")
                  ->orWhere('phone', 'ilike', "%{$search}%");
            });
        }

        if ($request->filled('school')) {
            $query->where('school', $request->input('school'));
        }

        if ($request->filled('pretest')) {
            $query->where('has_completed_pretest', $request->input('pretest') === 'yes');
        }

        if ($request->filled('posttest')) {
            $query->where('has_completed_posttest', $request->input('posttest') === 'yes');
        }

        $respondents = $query->orderBy('created_at', 'desc')->paginate(15)->withQueryString();

        $schools = Profile::select('school')
            ->whereNotNull('school')
            ->where('school', '!=', '')
            ->distinct()
            ->pluck('school');

        return Inertia::render('Admin/Respondents/Index', [
            'respondents' => $respondents,
            'filters' => $request->only(['search', 'school', 'pretest', 'posttest']),
            'schools' => $schools,
        ]);
    }

    public function show(string $id): Response
    {
        $respondent = Profile::findOrFail($id);
        $habits = DailyHabit::where('user_id', $id)->orderBy('log_date', 'desc')->get();
        $risks = RiskResult::where('user_id', $id)->orderBy('created_at', 'desc')->get();

        // Survey responses
        $pretestResponses = DB::table('survey_responses as sr')
            ->join('survey_instruments as si', 'sr.instrument_id', '=', 'si.id')
            ->join('survey_options as so', 'sr.selected_option_id', '=', 'so.id')
            ->where('sr.user_id', $id)
            ->where('sr.type', 'pretest')
            ->select('si.variable', 'si.question_text', 'so.option_text', 'so.score', 'sr.created_at')
            ->orderBy('si.question_order')
            ->get();

        $posttestResponses = DB::table('survey_responses as sr')
            ->join('survey_instruments as si', 'sr.instrument_id', '=', 'si.id')
            ->join('survey_options as so', 'sr.selected_option_id', '=', 'so.id')
            ->where('sr.user_id', $id)
            ->where('sr.type', 'posttest')
            ->select('si.variable', 'si.question_text', 'so.option_text', 'so.score', 'sr.created_at')
            ->orderBy('si.question_order')
            ->get();

        return Inertia::render('Admin/Respondents/Show', [
            'respondent' => $respondent,
            'habits' => $habits,
            'risks' => $risks,
            'pretestResponses' => $pretestResponses,
            'posttestResponses' => $posttestResponses,
        ]);
    }

    public function export(): StreamedResponse
    {
        $filename = 'uticare_respondents_' . date('Y-m-d_His') . '.csv';

        return response()->streamDownload(function () {
            $handle = fopen('php://output', 'w');
            
            // UTF-8 BOM for Excel
            fputs($handle, "\xEF\xBB\xBF");

            // CSV Headers
            fputcsv($handle, [
                'ID Responden',
                'Nama Lengkap',
                'Sekolah',
                'Kelas',
                'Usia',
                'No WhatsApp',
                'Status Pre-test',
                'Tanggal Pre-test',
                'Skor Pre-test Pengetahuan',
                'Skor Pre-test Sikap',
                'Skor Pre-test Perilaku',
                'Total Skor Pre-test',
                'Status Post-test',
                'Tanggal Post-test',
                'Skor Post-test Pengetahuan',
                'Skor Post-test Sikap',
                'Skor Post-test Perilaku',
                'Total Skor Post-test',
                'Total Hari Log Kebiasaan',
                'Rata-rata Air Minum (gelas)',
                'Kepatuhan Tidak Menahan BAK (%)',
                'Rata-rata Skor Kebiasaan',
                'Risiko ISK Terakhir',
                'Skor Risiko Terakhir',
                'Tanggal Daftar',
            ]);

            $profiles = Profile::orderBy('created_at', 'asc')->get();

            foreach ($profiles as $p) {
                // Pre-test scores by variable
                $preScores = DB::table('survey_responses as sr')
                    ->join('survey_options as so', 'sr.selected_option_id', '=', 'so.id')
                    ->join('survey_instruments as si', 'sr.instrument_id', '=', 'si.id')
                    ->where('sr.user_id', $p->id)
                    ->where('sr.type', 'pretest')
                    ->select('si.variable', DB::raw('SUM(so.score) as total'))
                    ->groupBy('si.variable')
                    ->pluck('total', 'variable');

                // Post-test scores by variable
                $postScores = DB::table('survey_responses as sr')
                    ->join('survey_options as so', 'sr.selected_option_id', '=', 'so.id')
                    ->join('survey_instruments as si', 'sr.instrument_id', '=', 'si.id')
                    ->where('sr.user_id', $p->id)
                    ->where('sr.type', 'posttest')
                    ->select('si.variable', DB::raw('SUM(so.score) as total'))
                    ->groupBy('si.variable')
                    ->pluck('total', 'variable');

                // Habit stats
                $habitStats = DailyHabit::where('user_id', $p->id)->select(
                    DB::raw('COUNT(*) as total_days'),
                    DB::raw('ROUND(AVG(water_intake), 1) as avg_water'),
                    DB::raw('ROUND(AVG(CASE WHEN no_hold_urine THEN 1 ELSE 0 END) * 100, 1) as pct_no_hold'),
                    DB::raw('ROUND(AVG(habit_score), 1) as avg_score')
                )->first();

                // Latest risk
                $latestRisk = RiskResult::where('user_id', $p->id)->orderBy('created_at', 'desc')->first();

                $prePeng = $preScores['pengetahuan'] ?? 0;
                $preSik = $preScores['sikap'] ?? 0;
                $prePer = $preScores['perilaku'] ?? 0;
                $preTot = $prePeng + $preSik + $prePer;

                $postPeng = $postScores['pengetahuan'] ?? 0;
                $postSik = $postScores['sikap'] ?? 0;
                $postPer = $postScores['perilaku'] ?? 0;
                $postTot = $postPeng + $postSik + $postPer;

                fputcsv($handle, [
                    $p->id,
                    $p->full_name,
                    $p->school ?? '-',
                    $p->class ?? '-',
                    $p->age ?? '-',
                    $p->phone ?? '-',
                    $p->has_completed_pretest ? 'Selesai' : 'Belum',
                    $p->pretest_completed_at ? $p->pretest_completed_at->format('Y-m-d H:i') : '-',
                    $prePeng,
                    $preSik,
                    $prePer,
                    $preTot,
                    $p->has_completed_posttest ? 'Selesai' : 'Belum',
                    $p->posttest_completed_at ? $p->posttest_completed_at->format('Y-m-d H:i') : '-',
                    $postPeng,
                    $postSik,
                    $postPer,
                    $postTot,
                    $habitStats->total_days ?? 0,
                    $habitStats->avg_water ?? 0,
                    $habitStats->pct_no_hold ?? 0,
                    $habitStats->avg_score ?? 0,
                    $latestRisk ? strtoupper($latestRisk->risk_level) : '-',
                    $latestRisk ? $latestRisk->total_score : '-',
                    $p->created_at ? $p->created_at->format('Y-m-d H:i') : '-',
                ]);
            }

            fclose($handle);
        }, $filename, [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => "attachment; filename=\"$filename\"",
        ]);
    }
}
