<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('modules')) {
            Schema::create('modules', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('title');
                $table->string('category');
                $table->string('duration');
                $table->text('icon')->nullable();
                $table->string('icon_name')->nullable();
                $table->string('video_url')->nullable();
                $table->longText('content')->nullable();
                $table->integer('view_count')->default(0);
            });
        } else {
            Schema::table('modules', function (Blueprint $table) {
                if (!Schema::hasColumn('modules', 'icon')) {
                    $table->text('icon')->nullable()->after('duration');
                }
                if (!Schema::hasColumn('modules', 'content')) {
                    $table->longText('content')->nullable()->after('icon');
                }
            });
        }
    }

    public function down(): void
    {
        //
    }
};
