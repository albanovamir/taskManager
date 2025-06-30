document.addEventListener('DOMContentLoaded', function() {
    const token = localStorage.getItem('token');
    if (!token) {
        window.location.href = '/login.html';
        return;
    }
    
    // Modal functionality
    const createTeamBtn = document.getElementById('createTeamBtn');
    const createTeamModal = document.getElementById('createTeamModal');
    const closeModal = document.querySelector('.close');
    
    if (createTeamBtn && createTeamModal) {
        createTeamBtn.addEventListener('click', function() {
            createTeamModal.style.display = 'block';
        });
        
        closeModal.addEventListener('click', function() {
            createTeamModal.style.display = 'none';
        });
        
        window.addEventListener('click', function(event) {
            if (event.target === createTeamModal) {
                createTeamModal.style.display = 'none';
            }
        });
    }
    
    // Create team form
    const createTeamForm = document.getElementById('createTeamForm');
    if (createTeamForm) {
        createTeamForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const teamName = document.getElementById('teamName').value;
            
            fetch('http://localhost:8080/teams', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({
                    name: teamName
                })
            })
            .then(response => {
                if (!response.ok) {
                    return response.json().then(err => { throw err; });
                }
                return response.json();
            })
            .then(() => {
                createTeamModal.style.display = 'none';
                createTeamForm.reset();
                loadTeams();
            })
            .catch(error => {
                alert(error.error || 'Failed to create team');
            });
        });
    }
    
    // Load teams
    loadTeams();
    
    function loadTeams() {
        fetch('http://localhost:8080/teams', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(response => response.json())
        .then(teams => {
            console.log('teams:', teams);
            
            const teamsList = document.getElementById('teamsList');
            teamsList.innerHTML = '';
            
            teams.forEach(team => {
                const teamCard = document.createElement('div');
                teamCard.className = 'team-card';
                
                teamCard.innerHTML = `
                    <div class="team-header">
                        <div>
                            <span class="team-name">${team.Name}</span>
                            <span class="team-owner">Owner: ${team.Owner.Username}</span>
                        </div>
                        <div>
                            <button class="btn btn-danger delete-team" data-id="${team.ID}">Delete</button>
                        </div>
                    </div>
                    <div class="team-members">
                        <h4>Members</h4>
                        <div class="member-list" id="members-${team.ID}">
                            ${team.Members.map(member => `
                                <span class="member-tag">${member.Username}
                                    ${team.OwnerID !== member.ID ? `<button class="remove-member" data-team-id="${team.ID}" data-user-id="${member.ID}">×</button>` : ''}
                                </span>
                            `).join('')}
                        </div>
                        <form class="add-member-form" data-team-id="${team.ID}">
                            <input type="text" placeholder="User ID" required>
                            <button type="submit" class="btn btn-secondary">Add Member</button>
                        </form>
                    </div>
                `;
                
                teamsList.appendChild(teamCard);
            });
            
            // Add event listeners for delete buttons
            document.querySelectorAll('.delete-team').forEach(button => {
                button.addEventListener('click', function() {
                    const teamId = this.getAttribute('data-id');
                    deleteTeam(teamId);
                });
            });
            
            // Add event listeners for remove member buttons
            document.querySelectorAll('.remove-member').forEach(button => {
                button.addEventListener('click', function() {
                    const teamId = this.getAttribute('data-team-id');
                    const userId = this.getAttribute('data-user-id');
                    removeMember(teamId, userId);
                });
            });
            
            // Add event listeners for add member forms
            document.querySelectorAll('.add-member-form').forEach(form => {
                form.addEventListener('submit', function(e) {
                    e.preventDefault();
                    const teamId = this.getAttribute('data-team-id');
                    const userId = this.querySelector('input').value;
                    addMember(teamId, userId);
                });
            });
        });
    }
    
    function deleteTeam(teamId) {
        if (!confirm('Are you sure you want to delete this team?')) return;
        
        fetch(`http://localhost:8080/teams/${teamId}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(response => {
            if (!response.ok) {
                return response.json().then(err => { throw err; });
            }
            loadTeams();
        })
        .catch(error => {
            alert(error.error || 'Failed to delete team');
        });
    }
    
    function addMember(teamId, userId) {
        fetch(`http://localhost:8080/teams/${teamId}/members`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                user_id: parseInt(userId)
            })
        })
        .then(response => {
            if (!response.ok) {
                return response.json().then(err => { throw err; });
            }
            loadTeams();
        })
        .catch(error => {
            alert(error.error || 'Failed to add member');
        });
    }
    
    function removeMember(teamId, userId) {
        fetch(`http://localhost:8080/teams/${teamId}/members/${userId}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(response => {
            if (!response.ok) {
                return response.json().then(err => { throw err; });
            }
            loadTeams();
        })
        .catch(error => {
            alert(error.error || 'Failed to remove member');
        });
    }
});