package main

import (
	"log"
	"os"
	"task-manager-backend/handlers"
	"task-manager-backend/middleware"
	"task-manager-backend/models"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	// Load environment variables
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	// Database connection
	dsn := "host=" + os.Getenv("DB_HOST") + " user=" + os.Getenv("DB_USER") + " password=" + os.Getenv("DB_PASSWORD") + " dbname=" + os.Getenv("DB_NAME") + " port=" + os.Getenv("DB_PORT") + " sslmode=disable TimeZone=UTC"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database")
	}

	// AutoMigrate models
	db.AutoMigrate(&models.User{}, &models.Team{}, &models.Task{})

	// Initialize Gin router
	r := gin.Default()

	// CORS middleware
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// Auth routes
	authHandler := handlers.NewAuthHandler(db)
	r.POST("/register", authHandler.Register)
	r.POST("/login", authHandler.Login)

	// Protected routes
	auth := r.Group("/")
	auth.Use(middleware.AuthMiddleware())
	{
		auth.GET("/current-user", authHandler.GetCurrentUser)
		teamHandler := handlers.NewTeamHandler(db)
		auth.GET("/teams/:id", teamHandler.GetTeam)
		auth.GET("/teams", teamHandler.GetTeams)
		auth.POST("/teams", teamHandler.CreateTeam)
		auth.DELETE("/teams/:id", teamHandler.DeleteTeam)
		auth.POST("/teams/:id/members", teamHandler.AddMember)
		auth.DELETE("/teams/:id/members/:userId", teamHandler.RemoveMember)

		taskHandler := handlers.NewTaskHandler(db)
		auth.GET("/tasks", taskHandler.GetTasks)
		auth.POST("/tasks", taskHandler.CreateTask)
		auth.PUT("/tasks/:id/complete", taskHandler.MarkTaskComplete)
		auth.DELETE("/tasks/:id", taskHandler.DeleteTask)
	}

	// Start server
	r.Run(":8080")
}
