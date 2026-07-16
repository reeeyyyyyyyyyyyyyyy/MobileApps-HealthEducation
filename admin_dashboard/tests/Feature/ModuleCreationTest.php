<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Admin;
use App\Models\Module;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ModuleCreationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_module_create_page_requires_auth()
    {
        $response = $this->get('/admin/modules/create');
        $response->assertRedirect('/admin/login');
    }

    public function test_admin_can_view_create_form()
    {
        $admin = Admin::factory()->create();
        $this->actingAs($admin);

        $response = $this->get('/admin/modules/create');
        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page->component('Admin/Modules/Form'));
    }

    public function test_admin_can_create_module()
    {
        $admin = Admin::factory()->create();
        $this->actingAs($admin);

        $response = $this->post('/admin/modules', [
            'title' => 'Memahami Siklus Menstruasi',
            'category' => 'Pengetahuan',
            'duration' => '8 menit',
            'icon_name' => 'psychology_rounded',
            'video_url' => 'https://youtube.com/watch?v=test',
            'content' => '<h2>Apa Itu Siklus Menstruasi?</h2><p>Siklus menstruasi adalah proses alami yang dialami remaja putri.</p>',
        ]);

        $response->assertSessionHas('success', 'Modul edukasi berhasil dibuat!');

        $this->assertDatabaseHas('modules', [
            'title' => 'Memahami Siklus Menstruasi',
            'category' => 'Pengetahuan',
        ]);
    }

    public function test_module_validation_fails_without_title()
    {
        $admin = Admin::factory()->create();
        $this->actingAs($admin);

        $response = $this->post('/admin/modules', [
            'category' => 'Pengetahuan',
            'duration' => '5 menit',
            'content' => 'Konten test',
        ]);

        $response->assertSessionHasErrors('title');
    }

    public function test_module_can_store_html_content()
    {
        $admin = Admin::factory()->create();
        $this->actingAs($admin);

        $htmlContent = '<h1>Judul</h1><p>Paragraf <strong>tebal</strong> dan <em>miring</em></p><ul><li>Item 1</li><li>Item 2</li></ul>';

        $this->post('/admin/modules', [
            'title' => 'Modul HTML Test',
            'category' => 'Pengetahuan',
            'duration' => '3 menit',
            'icon_name' => 'psychology_rounded',
            'content' => $htmlContent,
        ]);

        $this->assertDatabaseHas('modules', [
            'title' => 'Modul HTML Test',
            'content' => $htmlContent,
        ]);
    }
}
