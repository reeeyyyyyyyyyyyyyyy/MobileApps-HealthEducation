<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        if (DB::connection()->getDriverName() !== 'pgsql') return;

        DB::statement('ALTER TABLE modules ALTER COLUMN published DROP DEFAULT');
        DB::statement('ALTER TABLE modules ALTER COLUMN published TYPE smallint USING CASE WHEN published THEN 1 ELSE 0 END');
        DB::statement('ALTER TABLE modules ALTER COLUMN published SET DEFAULT 1');
    }

    public function down(): void
    {
        if (DB::connection()->getDriverName() !== 'pgsql') return;

        DB::statement('ALTER TABLE modules ALTER COLUMN published DROP DEFAULT');
        DB::statement('ALTER TABLE modules ALTER COLUMN published TYPE boolean USING CASE WHEN published = 1 THEN true ELSE false END');
        DB::statement('ALTER TABLE modules ALTER COLUMN published SET DEFAULT true');
    }
};
