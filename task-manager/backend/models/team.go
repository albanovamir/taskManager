package models

import "gorm.io/gorm"

type Team struct {
	gorm.Model
	Name    string `gorm:"not null"`
	OwnerID uint   `gorm:"not null"`
	Owner   User   `gorm:"foreignKey:OwnerID"`
	Members []User `gorm:"many2many:user_teams;"`
	Tasks   []Task `gorm:"foreignKey:TeamID"`
}
