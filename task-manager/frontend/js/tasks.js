document.addEventListener('DOMContentLoaded', function() {
    const token = localStorage.getItem('token');
    if (!token) {
        window.location.href = '/login.html';
        return;
    }
    
    // Modal functionality
    const createTaskBtn = document.getElementById('createTaskBtn');
    const createTaskModal = document.getElementById('createTaskModal');
    const closeModal = document.querySelector('.close');
    
    if (createTaskBtn && createTaskModal) {
        createTaskBtn.addEventListener('click', function() {
            loadTeamsForTaskCreation();
            createTaskModal.style.display = 'block';
        });
        
        closeModal.addEventListener('click', function() {
            createTaskModal.style.display = 'none';
        });
        
        window.addEventListener('click', function(event) {
            if (event.target === createTaskModal) {
                createTaskModal.style.display = 'none';
            }
        });
    }

    function loadTeamsForTaskCreation() {
    const token = localStorage.getItem('token'); // Получаем токен из хранилища
    
    fetch('http://localhost:8080/teams', {
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
        }
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
    })
    .then(teams => {
        console.log('Received teams:', teams);
        const teamSelect = document.getElementById('taskTeam');
        teamSelect.innerHTML = '<option value="">Select team</option>'; // Добавляем пустую опцию
        
        if (!teams || teams.length === 0) {
            console.warn('No teams available');
            return;
        }
        
        teams.forEach(team => {
            const option = document.createElement('option');
            option.value = team.ID; // Обратите внимание на ID (должен совпадать с бэкендом)
            option.textContent = team.Name;
            teamSelect.appendChild(option);
        });
        
        // Не загружаем участников автоматически
        // Ждём явного выбора пользователя
    })
    .catch(error => {
        console.error('Error loading teams:', error);
        alert('Failed to load teams. Please try again later.');
    });
    
    // Обработчик изменения выбора команды
    document.getElementById('taskTeam').addEventListener('change', function() {
        if (this.value) {
            loadTeamMembers(this.value);
        } else {
            // Очищаем список участников, если команда не выбрана
            document.getElementById('taskAssignee').innerHTML = '<option value="">None</option>';
        }
    });
    }
    
    function loadTeamMembers(teamId) {
      console.log('Current token:', token);
      
      fetch(`http://localhost:8080/teams/${teamId}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })
      .then(response => response.json())
      .then(team => {
            const assigneeSelect = document.getElementById('taskAssignee');
            assigneeSelect.innerHTML = '<option value="">None</option>';
            
            team.Members.forEach(Member => {
                const option = document.createElement('option');
                option.value = Member.ID;
                option.textContent = Member.Username;
                assigneeSelect.appendChild(option);
            });
        });
    }
    
    // Create task form
    const createTaskForm = document.getElementById('createTaskForm');
    if (createTaskForm) {
        createTaskForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const title = document.getElementById('taskTitle').value;
            const description = document.getElementById('taskDescription').value;
            const teamId = document.getElementById('taskTeam').value;
            const assigneeId = document.getElementById('taskAssignee').value;
            
            fetch('http://localhost:8080/tasks', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({
                    title: title,
                    description: description,
                    team_id: parseInt(teamId),
                    assignee_id: assigneeId ? parseInt(assigneeId) : null
                })
            })
            .then(response => {
                if (!response.ok) {
                    return response.json().then(err => { throw err; });
                }
                return response.json();
            })
            .then(() => {
                createTaskModal.style.display = 'none';
                createTaskForm.reset();
                loadTasks();
            })
            .catch(error => {
                alert(error.error || 'Failed to create task');
            });
        });
    }
    
    // Load tasks
    loadTasks();
    
    function loadTasks() {
    console.log(token);

        fetch('http://localhost:8080/tasks', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(response => response.json())
        .then(tasks => {
            console.log('Recieved tasks:', tasks);
            
            const tasksList = document.getElementById('tasksList');
            tasksList.innerHTML = '';
            
            tasks.forEach(task => {
                const taskCard = document.createElement('div');
                taskCard.className = `task-card ${task.Completed ? 'completed' : ''}`;
                
                taskCard.innerHTML = `
                    <div class="task-header">
                        <span class="task-title ${task.Completed ? 'task-completed' : ''}">${task.Title}</span>
                        <div>
                            ${!task.Completed ? `
                                <button class="btn btn-secondary complete-task" data-id="${task.ID}">Complete</button>
                            ` : ''}
                            <button class="btn btn-danger delete-task" data-id="${task.ID}">Delete</button>
                        </div>
                    </div>
                    <div class="task-team">Team: ${task.Team ? task.Team.Name : 'None'}</div>
                    ${task.Description ? `<div class="task-description">${task.Description}</div>` : ''}
                    <div class="task-footer">
                        <span>Assignee: ${task.Assignee ? task.Assignee.Username : 'Unassigned'}</span>
                        <span>Created by: ${task.Creator ? task.Creator.Username : 'Unknown'}</span>
                    </div>
                `;
                
                tasksList.appendChild(taskCard);
            });
            
            // Add event listeners for complete buttons
            document.querySelectorAll('.complete-task').forEach(button => {
                button.addEventListener('click', function() {
                    const taskId = this.getAttribute('data-id');
                    completeTask(taskId);
                });
            });
            
            // Add event listeners for delete buttons
            document.querySelectorAll('.delete-task').forEach(button => {
                button.addEventListener('click', function() {
                    const taskId = this.getAttribute('data-id');
                    deleteTask(taskId);
                });
            });
        });
    }
    
    function completeTask(taskId) {
        fetch(`http://localhost:8080/tasks/${taskId}/complete`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(response => {
            if (!response.ok) {
                return response.json().then(err => { throw err; });
            }
            loadTasks();
        })
        .catch(error => {
            alert(error.error || 'Failed to complete task');
        });
    }
    
    function deleteTask(taskId) {
        if (!confirm('Are you sure you want to delete this task?')) return;
        
        fetch(`http://localhost:8080/tasks/${taskId}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(response => {
            if (!response.ok) {
                return response.json().then(err => { throw err; });
            }
            loadTasks();
        })
        .catch(error => {
            alert(error.error || 'Failed to delete task');
        });
    }
});