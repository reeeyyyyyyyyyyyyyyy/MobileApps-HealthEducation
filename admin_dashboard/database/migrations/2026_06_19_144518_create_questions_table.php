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
        if (! Schema::hasTable('questions')) {
            Schema::create('questions', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('quiz_id');
                $table->foreign('quiz_id')->references('id')->on('quizzes')->cascadeOnDelete();
                $table->text('question_text');
                $table->json('options');
                $table->integer('correct_index');
                $table->text('explanation')->nullable();
                $table->timestamps();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('questions');
    }
};
