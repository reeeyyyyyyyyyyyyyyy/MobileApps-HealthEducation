<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (! Schema::hasTable('quizzes')) {
            Schema::create('quizzes', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('module_id');
                $table->foreign('module_id')->references('id')->on('modules')->cascadeOnDelete();
                $table->string('title');
                $table->text('description')->nullable();
                $table->integer('xp_reward')->default(100);
                $table->timestamps();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('quizzes');
    }
};
