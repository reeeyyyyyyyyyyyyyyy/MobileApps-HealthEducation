<?php

namespace App\Console\Commands;

use Illuminate\Support\Facades\DB;
use Illuminate\Console\Command;

class PublishScheduledModules extends Command
{
    protected $signature = 'modules:publish-scheduled';
    protected $description = 'Publish modules that are scheduled for release';

    public function handle(): int
    {
        $count = DB::table('modules')
            ->whereRaw('published = 0')
            ->whereNotNull('scheduled_at')
            ->where('scheduled_at', '<=', now())
            ->update(['published' => 1]);

        if ($count > 0) {
            $this->info("Published {$count} scheduled modules.");
        }

        return Command::SUCCESS;
    }
}
