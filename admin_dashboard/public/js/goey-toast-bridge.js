/**
 * Goey Toast Bridge — Intercepts Filament/Livewire notifications
 * and forwards them to the goey-toast vanilla JS implementation.
 */
(function () {
    'use strict';

    function waitForGoeyToast(callback, maxAttempts) {
        var attempts = 0;
        var limit = maxAttempts || 20;
        var interval = setInterval(function () {
            if (window.goeyToast) {
                clearInterval(interval);
                callback();
            } else if (++attempts >= limit) {
                clearInterval(interval);
            }
        }, 100);
    }

    waitForGoeyToast(function () {

        // 1. Intercept Filament Livewire notifications via custom event
        document.addEventListener('filament-notification', function (e) {
            var detail = e.detail || {};
            var title = detail.title || detail.body || 'Notifikasi';
            var type = detail.status || detail.color || 'success';

            var typeMap = {
                'success': 'success',
                'danger': 'error',
                'warning': 'warning',
                'info': 'info',
                'primary': 'info',
            };

            var toastType = typeMap[type] || 'success';
            window.goeyToast[toastType](title);
        });

        // 2. Listen for Livewire events (Filament dispatches these)
        if (window.Livewire) {
            try {
                window.Livewire.hook('request', function (payload) {
                    // After Livewire processes, check for notifications
                    // This is a passive listener
                });
            } catch (e) {
                // Livewire v3 may not support this hook pattern
            }
        }

        // 3. MutationObserver — watch for Filament notification DOM elements
        //    and convert them to goey-toast instead
        var observer = new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                mutation.addedNodes.forEach(function (node) {
                    if (node.nodeType !== 1) return;

                    // Filament notification wrapper
                    var notification = node.querySelector
                        ? node.querySelector('[x-data*="notification"]') || 
                          (node.matches && node.matches('[x-data*="notification"]') ? node : null)
                        : null;

                    if (!notification) return;

                    // Extract text content
                    var titleEl = notification.querySelector('.fi-no-title, [class*="title"]');
                    var title = titleEl ? titleEl.textContent.trim() : '';

                    if (!title) return;

                    // Determine type from color classes
                    var type = 'success';
                    var classes = notification.className || '';
                    if (classes.indexOf('danger') > -1 || classes.indexOf('red') > -1) type = 'error';
                    else if (classes.indexOf('warning') > -1 || classes.indexOf('amber') > -1 || classes.indexOf('yellow') > -1) type = 'warning';
                    else if (classes.indexOf('info') > -1 || classes.indexOf('blue') > -1) type = 'info';

                    // Fire goey toast
                    window.goeyToast[type](title);

                    // Hide the original Filament notification
                    notification.style.display = 'none';
                    var parent = notification.closest('.fi-no-notification, [wire\\:key*="notification"]');
                    if (parent) parent.style.display = 'none';
                });
            });
        });

        observer.observe(document.body, { childList: true, subtree: true });

        // 4. Also intercept Alpine.js $dispatch events for notifications
        document.addEventListener('notify', function (e) {
            var detail = e.detail || {};
            var msg = detail.message || detail.title || '';
            var type = detail.type || 'success';
            if (msg && window.goeyToast[type]) {
                window.goeyToast[type](msg);
            }
        });
    });
})();
