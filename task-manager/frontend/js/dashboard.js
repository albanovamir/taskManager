document.addEventListener('DOMContentLoaded', function() {
    const token = localStorage.getItem('token');
    if (!token) {
        window.location.href = '/login.html';
        return;
    }
    console.log(token);
    
    // // Display username (you might want to fetch this from an API endpoint)
    // const usernameDisplay = document.getElementById('usernameDisplay');
    // const tokenPayload = JSON.parse(atob(token.split('.')[1]));
    // usernameDisplay.textContent = tokenPayload.user_id; // In a real app, you'd fetch the username

    // (новый вариант с запросом):
    function loadCurrentUser() {
        fetch('http://localhost:8080/current-user', {
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Failed to fetch user data');
            }
            return response.json();
        })
        .then(data => {
            console.log('user:', data)
            document.getElementById('usernameDisplay').textContent = data.Username;
        })
        .catch(error => {
            console.error('Error loading user:', error);
            document.getElementById('usernameDisplay').textContent = 'User';
        });
    }

    // Вызываем при загрузке страницы
    loadCurrentUser();
    
    // Fetch stats
    fetchStats();
    
    function fetchStats() {
        // Fetch teams count
        fetch('http://localhost:8080/teams', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(response => response.json())
        .then(teams => {
            document.getElementById('teamsCount').textContent = teams.length;
        });
        
        // Fetch tasks count
        fetch('http://localhost:8080/tasks', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(response => response.json())
        .then(tasks => {
            document.getElementById('tasksCount').textContent = tasks.length;
            const completedCount = tasks.filter(task => task.Completed).length;
            document.getElementById('completedCount').textContent = completedCount;
        });
    }
});