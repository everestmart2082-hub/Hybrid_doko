package controllers

import (
	"context"
	"crypto/rand"
	"errors"
	"fmt"
	"math/big"
	"net/http"
	"os"
	"strings"
	"time"

	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// GenerateOTP creates a random 6-digit numeric string
func GenerateOTP() (string, error) {
	max := big.NewInt(1000000)
	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		return "", err
	}
	// Pad with leading zeroes to ensure 6 digits (%06s would pad with spaces for strings)
	return fmt.Sprintf("%06d", n.Int64()), nil
}

// GenerateJWT creates a JWT token including the user ID and role
func GenerateJWT(userID primitive.ObjectID, role string) (string, error) {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return "", errors.New("JWT_SECRET environment variable is empty")
	}

	claims := jwt.MapClaims{
		"id":   userID.Hex(),
		"role": role,
		"exp":  time.Now().Add(time.Hour * 72).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret))
}

// VerifyToken parses and validates a raw JWT string manually
func VerifyToken(tokenString string) (jwt.MapClaims, error) {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return nil, errors.New("JWT_SECRET not configured")
	}

	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(secret), nil
	})

	if err != nil || !token.Valid {
		return nil, errors.New("invalid or expired token")
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil, errors.New("invalid token claims")
	}

	return claims, nil
}

// TryVendorHexIDFromBearer returns the vendor's Mongo hex id from a valid Bearer JWT (role=vendor), or ("", false).
func TryVendorHexIDFromBearer(c *gin.Context) (string, bool) {
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		return "", false
	}
	parts := strings.Split(authHeader, " ")
	if len(parts) != 2 || parts[0] != "Bearer" {
		return "", false
	}
	claims, err := VerifyToken(parts[1])
	if err != nil {
		return "", false
	}
	role, _ := claims["role"].(string)
	if role != "vendor" {
		return "", false
	}
	id, _ := claims["id"].(string)
	if id == "" {
		return "", false
	}
	return id, true
}

// AuthMiddleware generates a Gin middleware that ensures the request contains a valid JWT for the specified roles.
func AuthMiddleware(allowedRoles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header is required"})
			c.Abort()
			return
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header format must be Bearer {token}"})
			c.Abort()
			return
		}

		secret := os.Getenv("JWT_SECRET")
		if secret == "" {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "JWT_SECRET not configured"})
			c.Abort()
			return
		}

		token, err := jwt.Parse(parts[1], func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, errors.New("unexpected signing method")
			}
			return []byte(secret), nil
		})

		if err != nil || !token.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
			c.Abort()
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token claims"})
			c.Abort()
			return
		}

		roleFromToken, ok := claims["role"].(string)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Role missing in token"})
			c.Abort()
			return
		}

		// Check if the user's role is in the allowedRoles list
		roleAllowed := false
		if len(allowedRoles) == 0 {
			roleAllowed = true // If no roles passed, basically just validates a valid token exists
		} else {
			for _, role := range allowedRoles {
				if role == roleFromToken {
					roleAllowed = true
					break
				}
			}
		}

		if !roleAllowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "You do not have permission to access this resource"})
			c.Abort()
			return
		}

		userIDStr, _ := claims["id"].(string)
		userID, err := primitive.ObjectIDFromHex(userIDStr)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user ID in token"})
			c.Abort()
			return
		}

		// Set the UserID and Role inside the gin Context mapping
		c.Set("userID", userID)
		c.Set("role", roleFromToken)

		if roleFromToken == "vendor" {
			vendorColl := utils.GetCollection("vendors")
			var v struct {
				Verified  bool `bson:"verified"`
				Suspended bool `bson:"suspended"`
			}
			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			defer cancel()
			err := vendorColl.FindOne(ctx, bson.M{"_id": userID}).Decode(&v)
			if err != nil || !v.Verified || v.Suspended {
				c.JSON(http.StatusForbidden, gin.H{"error": "account not verified or suspended"})
				c.Abort()
				return
			}
		}

		c.Next()
	}
}
