<?php

return [

    'middleware' => ['web'],

    'route_prefix' => 'reorderable',

    'sort_column' => 'sort_order',

    'allowed_models' => [
        // App\Models\Task::class,
    ],

    'authorize' => null,

    'demo' => [
        'enabled' => false,
        'middleware' => ['web'],
    ],

];
