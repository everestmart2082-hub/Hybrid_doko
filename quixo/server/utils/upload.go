package utils

import (
	"fmt"
	"io"
	"mime/multipart"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// SaveUploadedFile saves the provided multipart.FileHeader to the uploads directory.
// It generates a unique filename to prevent collisions and returns the relative path.
func SaveUploadedFile(file *multipart.FileHeader) (string, error) {
	// Ensure the "uploads" directory exists
	uploadDir := filepath.Join(".", "uploads")
	if err := os.MkdirAll(uploadDir, os.ModePerm); err != nil {
		return "", err
	}

	// Extract extension and generate a unique filename
	ext := filepath.Ext(file.Filename)
	base := strings.TrimSuffix(filepath.Base(file.Filename), ext)
	filename := fmt.Sprintf("%s_%d%s", base, time.Now().UnixNano(), ext)
	
	destPath := filepath.Join(uploadDir, filename)

	src, err := file.Open()
	if err != nil {
		return "", err
	}
	defer src.Close()

	out, err := os.Create(destPath)
	if err != nil {
		return "", err
	}
	defer out.Close()

	if _, err = io.Copy(out, src); err != nil {
		return "", err
	}

	// Return the relative URL path to be stored in the database
	return "/uploads/" + filename, nil
}
