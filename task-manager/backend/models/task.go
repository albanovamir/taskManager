package models

import "gorm.io/gorm"

type Task struct {
	gorm.Model
	Title       string `gorm:"not null"`
	Description string
	Completed   bool `gorm:"default:false"`
	TeamID      uint
	Team        Team `gorm:"foreignKey:TeamID"`
	AssigneeID  uint
	Assignee    User `gorm:"foreignKey:AssigneeID"`
	CreatorID   uint `gorm:"not null"`
	Creator     User `gorm:"foreignKey:CreatorID"`
}
