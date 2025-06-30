package handlers

import (
	"net/http"
	"strconv"
	"task-manager-backend/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type TeamHandler struct {
	db *gorm.DB
}

func NewTeamHandler(db *gorm.DB) *TeamHandler {
	return &TeamHandler{db: db}
}

type CreateTeamInput struct {
	Name string `json:"name" binding:"required"`
}

type AddMemberInput struct {
	UserID uint `json:"user_id" binding:"required"`
}

// В handlers/team.go добавьте новый метод
func (h *TeamHandler) GetTeam(c *gin.Context) {
	userID := c.MustGet("userID").(uint)
	teamID := c.Param("id")

	var team models.Team
	// Запрос с проверкой что пользователь имеет доступ к команде
	err := h.db.Preload("Members").
		Where("id = ? AND (owner_id = ? OR id IN (SELECT team_id FROM user_teams WHERE user_id = ?))",
			teamID, userID, userID).
		First(&team).Error

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Team not found or access denied"})
		return
	}

	c.JSON(http.StatusOK, team)
}

func (h *TeamHandler) GetTeams(c *gin.Context) {
	userID := c.MustGet("userID").(uint)

	var teams []models.Team
	if err := h.db.Preload("Members").Preload("Owner").Where("owner_id = ? OR id IN (SELECT team_id FROM user_teams WHERE user_id = ?)", userID, userID).Find(&teams).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch teams"})
		return
	}

	c.JSON(http.StatusOK, teams)
}

func (h *TeamHandler) CreateTeam(c *gin.Context) {
	userID := c.MustGet("userID").(uint)

	var input CreateTeamInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	team := models.Team{
		Name:    input.Name,
		OwnerID: userID,
	}

	if err := h.db.Create(&team).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create team"})
		return
	}

	// Add creator as a member
	if err := h.db.Model(&team).Association("Members").Append(&models.User{Model: gorm.Model{ID: userID}}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not add creator to team"})
		return
	}

	c.JSON(http.StatusCreated, team)
}

func (h *TeamHandler) DeleteTeam(c *gin.Context) {
	userID := c.MustGet("userID").(uint)
	teamID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid team ID"})
		return
	}

	var team models.Team
	if err := h.db.First(&team, teamID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Team not found"})
		return
	}

	if team.OwnerID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only the team owner can delete the team"})
		return
	}

	if err := h.db.Delete(&team).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not delete team"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Team deleted successfully"})
}

func (h *TeamHandler) AddMember(c *gin.Context) {
	userID := c.MustGet("userID").(uint)
	teamID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid team ID"})
		return
	}

	var input AddMemberInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var team models.Team
	if err := h.db.First(&team, teamID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Team not found"})
		return
	}

	if team.OwnerID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only the team owner can add members"})
		return
	}

	var user models.User
	if err := h.db.First(&user, input.UserID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	if err := h.db.Model(&team).Association("Members").Append(&user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not add member to team"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Member added successfully"})
}

func (h *TeamHandler) RemoveMember(c *gin.Context) {
	userID := c.MustGet("userID").(uint)
	teamID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid team ID"})
		return
	}

	memberID, err := strconv.Atoi(c.Param("userId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	var team models.Team
	if err := h.db.First(&team, teamID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Team not found"})
		return
	}

	if team.OwnerID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only the team owner can remove members"})
		return
	}

	var user models.User
	if err := h.db.First(&user, memberID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	if err := h.db.Model(&team).Association("Members").Delete(&user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not remove member from team"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Member removed successfully"})
}
