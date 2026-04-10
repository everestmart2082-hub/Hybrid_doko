package controllers

import (
	"context"
	"time"

	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func reviewTextFromDoc(doc bson.M) string {
	if s, ok := doc["message"].(string); ok && s != "" {
		return s
	}
	if s, ok := doc["description"].(string); ok {
		return s
	}
	return ""
}

// BuildReviewsPayload loads reviews for a product from the reviews collection (by product_id).
func BuildReviewsPayload(ctx context.Context, productID primitive.ObjectID) []gin.H {
	if productID.IsZero() {
		return nil
	}
	coll := utils.GetCollection("reviews")
	ucoll := utils.GetCollection("users")
	cctx, cancel := context.WithTimeout(ctx, 8*time.Second)
	defer cancel()

	cur, err := coll.Find(cctx, bson.M{"product_id": productID})
	if err != nil {
		return nil
	}
	var docs []bson.M
	_ = cur.All(cctx, &docs)

	out := make([]gin.H, 0, len(docs))
	for _, d := range docs {
		rid, _ := d["_id"].(primitive.ObjectID)
		uid, _ := d["user_id"].(primitive.ObjectID)
		userName := ""
		if !uid.IsZero() {
			var u bson.M
			if err := ucoll.FindOne(cctx, bson.M{"_id": uid}).Decode(&u); err == nil {
				if n, ok := u["name"].(string); ok && n != "" {
					userName = n
				} else if ph, ok := u["phone"].(string); ok {
					userName = ph
				}
			}
		}
		dateStr := ""
		switch dt := d["date"].(type) {
		case primitive.DateTime:
			dateStr = time.UnixMilli(int64(dt)).UTC().Format(time.RFC3339)
		case time.Time:
			dateStr = dt.UTC().Format(time.RFC3339)
		}
		out = append(out, gin.H{
			"review id": rid.Hex(),
			"user id":   uid.Hex(),
			"user name": userName,
			"message":   reviewTextFromDoc(d),
			"date":      dateStr,
		})
	}
	return out
}
