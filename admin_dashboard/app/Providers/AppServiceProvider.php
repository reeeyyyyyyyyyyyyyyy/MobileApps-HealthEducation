<?php

namespace App\Providers;

use Filament\Support\Facades\FilamentView;
use Filament\View\PanelsRenderHook;
use Illuminate\Support\Facades\Blade;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Inject custom CSS + goey-toast CSS into <head>
        FilamentView::registerRenderHook(
            PanelsRenderHook::HEAD_END,
            fn (): string => implode("\n", [
                '<link rel="stylesheet" href="' . asset('css/custom-filament.css') . '">',
                '<link rel="stylesheet" href="' . asset('css/goey-toast.css') . '">',
            ]),
        );

        // Inject goey-toast JS + bridge JS before </body>
        FilamentView::registerRenderHook(
            PanelsRenderHook::BODY_END,
            fn (): string => Blade::render('
                <script src="{{ asset(\'js/goey-toast.js\') }}"></script>
                <script src="{{ asset(\'js/goey-toast-bridge.js\') }}"></script>
                @if(session(\'success\'))
                    <script>
                        document.addEventListener("DOMContentLoaded", function() {
                            if (window.goeyToast) window.goeyToast.success("{{ session(\'success\') }}");
                        });
                    </script>
                @endif
                @if(session(\'error\'))
                    <script>
                        document.addEventListener("DOMContentLoaded", function() {
                            if (window.goeyToast) window.goeyToast.error("{{ session(\'error\') }}");
                        });
                    </script>
                @endif
            '),
        );
    }
}
