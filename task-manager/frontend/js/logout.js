const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) {
        console.log('helloButton');
        
        logoutBtn.addEventListener('click', function() {
            console.log('helloButtonClicked');
            localStorage.removeItem('token');
            window.location.href = '/login.html';
        });
        
        // Check authentication on dashboard pages
        const token = localStorage.getItem('token');
        if (!token) {
            window.location.href = '/login.html';
        }
    }