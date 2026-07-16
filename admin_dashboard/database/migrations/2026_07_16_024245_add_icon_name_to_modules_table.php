<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('modules', function (Blueprint $table) {
            if (!Schema::hasColumn('modules', 'icon_name')) {
                $table->string('icon_name', 50)->nullable()->after('id');
            }
            // Remove base64 icon column if exists (kita pake icon_name bukan base64 icon)
            if (Schema::hasColumn('modules', 'icon')) {
                $table->dropColumn('icon');
            }
        });
    }

    public function down(): void
    {
        Schema::table('modules', function (Blueprint $table) {
            $table->dropColumn('icon_name');
        });
    }
};
