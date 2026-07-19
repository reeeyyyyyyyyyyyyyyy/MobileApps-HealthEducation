<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('learning_paths')) {
            Schema::create('learning_paths', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('title');
                $table->text('description')->nullable();
                $table->integer('sort_order')->default(0);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('learning_path_modules')) {
            Schema::create('learning_path_modules', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('path_id');
                $table->uuid('module_id');
                $table->integer('sort_order')->default(0);
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('learning_path_modules');
        Schema::dropIfExists('learning_paths');
    }
};
