package handlers

import (
	"net/http"
	"strconv"
	"task-manager-backend/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type TaskHandler struct {
	db *gorm.DB
}

func NewTaskHandler(db *gorm.DB) *TaskHandler {
	return &TaskHandler{db: db}
}

type CreateTaskInput struct {
	Title       string `json:"title" binding:"required"`
	Description string `json:"description"`
	TeamID      uint   `json:"team_id" binding:"required"`
	AssigneeID  uint   `json:"assignee_id"`
}

func (h *TaskHandler) GetTasks(c *gin.Context) {
	userID := c.MustGet("userID").(uint)

	var tasks []models.Task
	if err := h.db.Preload("Team").Preload("Assignee").Preload("Creator").
		Where("creator_id = ? OR assignee_id = ? OR team_id IN (SELECT team_id FROM user_teams WHERE user_id = ?)", userID, userID, userID).
		Find(&tasks).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch tasks"})
		return
	}

	c.JSON(http.StatusOK, tasks)
}

func (h *TaskHandler) CreateTask(c *gin.Context) {
	userID := c.MustGet("userID").(uint)

	var input CreateTaskInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if user is a member of the team
	var count int64
	h.db.Model(&models.User{}).Joins("JOIN user_teams ON user_teams.user_id = users.id").
		Where("users.id = ? AND user_teams.team_id = ?", userID, input.TeamID).
		Count(&count)
	if count == 0 {
		c.JSON(http.StatusForbidden, gin.H{"error": "You are not a member of this team"})
		return
	}

	// If assignee is specified, check if they are a member of the team
	if input.AssigneeID != 0 {
		var assigneeCount int64
		h.db.Model(&models.User{}).Joins("JOIN user_teams ON user_teams.user_id = users.id").
			Where("users.id = ? AND user_teams.team_id = ?", input.AssigneeID, input.TeamID).
			Count(&assigneeCount)
		if assigneeCount == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Assignee is not a member of this team"})
			return
		}
	}

	task := models.Task{
		Title:       input.Title,
		Description: input.Description,
		TeamID:      input.TeamID,
		AssigneeID:  input.AssigneeID,
		CreatorID:   userID,
	}

	if err := h.db.Create(&task).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create task"})
		return
	}

	c.JSON(http.StatusCreated, task)
}

func (h *TaskHandler) MarkTaskComplete(c *gin.Context) {
	userID := c.MustGet("userID").(uint)
	taskID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid task ID"})
		return
	}

	var task models.Task
	if err := h.db.First(&task, taskID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Task not found"})
		return
	}

	// Only the assignee or creator can mark the task as complete
	if task.AssigneeID != userID && task.CreatorID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "You are not authorized to complete this task"})
		return
	}

	if err := h.db.Model(&task).Update("completed", true).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not update task"})
		return
	}

	c.JSON(http.StatusOK, task)
}

func (h *TaskHandler) DeleteTask(c *gin.Context) {
	userID := c.MustGet("userID").(uint)
	taskID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid task ID"})
		return
	}

	var task models.Task
	if err := h.db.First(&task, taskID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Task not found"})
		return
	}

	// Only the creator can delete the task
	if task.CreatorID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only the task creator can delete the task"})
		return
	}

	if err := h.db.Delete(&task).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not delete task"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Task deleted successfully"})
}
