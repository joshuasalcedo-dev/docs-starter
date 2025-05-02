// Custom JavaScript for the documentation app

// Function to add syntax highlighting to code blocks
function applySyntaxHighlighting() {
    // This is a placeholder for adding code syntax highlighting
    // You could integrate a library like Prism.js or highlight.js here
    console.log("Syntax highlighting applied");
}

// Function to add responsive behavior to the navigation drawer
function setupResponsiveNavigation() {
    const mql = window.matchMedia('(max-width: 800px)');
    
    function handleScreenSizeChange(e) {
        if (e.matches) {
            // Mobile view - close drawer
            const drawer = document.querySelector('vaadin-app-layout');
            if (drawer) {
                drawer.drawerOpened = false;
            }
        }
    }
    
    mql.addEventListener('change', handleScreenSizeChange);
    handleScreenSizeChange(mql);
}

// Initialize when the document is fully loaded
window.addEventListener('DOMContentLoaded', (event) => {
    applySyntaxHighlighting();
    setupResponsiveNavigation();
});
