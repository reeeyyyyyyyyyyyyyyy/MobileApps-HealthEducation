(function() {
    // Inject SVG Filter
    if (!document.getElementById('gooey-toast-filter')) {
        const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        svg.setAttribute('id', 'gooey-toast-filter');
        svg.setAttribute('style', 'visibility: hidden; position: absolute; width: 0; height: 0;');
        svg.innerHTML = `
            <defs>
                <filter id="goo">
                    <feGaussianBlur in="SourceGraphic" stdDeviation="6" result="blur" />
                    <feColorMatrix in="blur" mode="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 18 -8" result="goo" />
                    <feBlend in="SourceGraphic" in2="goo" />
                </filter>
            </defs>
        `;
        document.body.appendChild(svg);
    }

    // Inject Toast Container
    let container = document.querySelector('.goey-toast-container');
    if (!container) {
        container = document.createElement('div');
        container.className = 'goey-toast-container';
        document.body.appendChild(container);
    }

    window.goeyToast = {
        show: function(message, type = 'success') {
            const toast = document.createElement('div');
            toast.className = `goey-toast ${type}`;
            
            // Add icon depending on type (Anti-Emoji, using SVG Icon representation)
            let iconSvg = '';
            if (type === 'success') {
                iconSvg = `<svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5"></path></svg>`;
            } else {
                iconSvg = `<svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z"></path></svg>`;
            }

            toast.innerHTML = `${iconSvg}<span>${message}</span>`;
            container.appendChild(toast);

            // Auto dismiss after 4 seconds
            setTimeout(() => {
                toast.classList.add('fade-out');
                toast.addEventListener('animationend', () => {
                    toast.remove();
                });
            }, 4000);
        },
        success: function(message) {
            this.show(message, 'success');
        },
        error: function(message) {
            this.show(message, 'error');
        }
    };
})();
