/**
 * Goey Toast — Vanilla JS gooey morphing toast notifications
 * Types: success, error, warning, info
 */
(function () {
    'use strict';

    // Inject SVG Gooey Filter
    if (!document.getElementById('gooey-toast-filter')) {
        var svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        svg.setAttribute('id', 'gooey-toast-filter');
        svg.setAttribute('style', 'visibility:hidden;position:absolute;width:0;height:0');
        svg.innerHTML =
            '<defs>' +
            '<filter id="goo">' +
            '<feGaussianBlur in="SourceGraphic" stdDeviation="5" result="blur"/>' +
            '<feColorMatrix in="blur" mode="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 20 -9" result="goo"/>' +
            '<feBlend in="SourceGraphic" in2="goo"/>' +
            '</filter>' +
            '</defs>';
        document.body.appendChild(svg);
    }

    // Inject Toast Container
    var container = document.querySelector('.goey-toast-container');
    if (!container) {
        container = document.createElement('div');
        container.className = 'goey-toast-container';
        document.body.appendChild(container);
    }

    // Icon SVGs (no emoji, clean line icons)
    var icons = {
        success: '<svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5"/></svg>',
        error: '<svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>',
        warning: '<svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m0 3.75h.008M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/></svg>',
        info: '<svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z"/></svg>',
    };

    window.goeyToast = {
        show: function (message, type) {
            type = type || 'success';
            var toast = document.createElement('div');
            toast.className = 'goey-toast ' + type;

            var iconHtml = icons[type] || icons.success;
            toast.innerHTML =
                '<span class="goey-toast-icon">' + iconHtml + '</span>' +
                '<span class="goey-toast-text">' + message + '</span>';

            container.appendChild(toast);

            // Auto dismiss after 4 seconds
            setTimeout(function () {
                toast.classList.add('fade-out');
                toast.addEventListener('animationend', function () {
                    if (toast.parentNode) toast.parentNode.removeChild(toast);
                });
            }, 4000);
        },
        success: function (message) {
            this.show(message, 'success');
        },
        error: function (message) {
            this.show(message, 'error');
        },
        warning: function (message) {
            this.show(message, 'warning');
        },
        info: function (message) {
            this.show(message, 'info');
        },
    };
})();
