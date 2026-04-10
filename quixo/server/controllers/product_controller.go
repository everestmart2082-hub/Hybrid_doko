package controllers

import (
	"context"
	"net/http"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"

	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func parseProductPageLimit(c *gin.Context) (page, limit int64) {
	page = 1
	limit = 50
	if p := strings.TrimSpace(c.Query("page")); p != "" {
		if v, err := strconv.ParseInt(p, 10, 64); err == nil && v > 0 {
			page = v
		}
	}
	if l := strings.TrimSpace(c.Query("limit")); l != "" {
		if v, err := strconv.ParseInt(l, 10, 64); err == nil && v > 0 {
			limit = v
		}
	}
	if limit > 100 {
		limit = 100
	}
	return page, limit
}

func productSortBSON(sortKey string) bson.D {
	switch strings.ToLower(strings.TrimSpace(sortKey)) {
	case "price low to high", "price_asc":
		return bson.D{{Key: "price_per_unit", Value: 1}}
	case "price high to low", "price_desc":
		return bson.D{{Key: "price_per_unit", Value: -1}}
	case "rating":
		return bson.D{{Key: "rating", Value: -1}, {Key: "_id", Value: -1}}
	case "discount":
		return bson.D{{Key: "discount", Value: -1}, {Key: "_id", Value: -1}}
	case "oldest":
		return bson.D{{Key: "_id", Value: 1}}
	case "newest":
		return bson.D{{Key: "_id", Value: -1}}
	default:
		return bson.D{{Key: "_id", Value: -1}}
	}
}

func objectIDFromProductDoc(p bson.M) (primitive.ObjectID, bool) {
	if id, ok := p["_id"].(primitive.ObjectID); ok {
		return id, true
	}
	if s, ok := p["_id"].(string); ok {
		if oid, err := primitive.ObjectIDFromHex(s); err == nil {
			return oid, true
		}
	}
	return primitive.NilObjectID, false
}

func bsonStringField(v interface{}) string {
	if v == nil {
		return ""
	}
	if s, ok := v.(string); ok {
		return s
	}
	return ""
}

type productDocScore struct {
	doc bson.M
	rel float64
}

func idLess(a, b interface{}) bool {
	ida, ok1 := a.(primitive.ObjectID)
	idb, ok2 := b.(primitive.ObjectID)
	if ok1 && ok2 {
		return ida.Hex() < idb.Hex()
	}
	return false
}

func productDocLessByKey(a, b bson.M, sortKey string) bool {
	switch strings.ToLower(strings.TrimSpace(sortKey)) {
	case "price low to high", "price_asc":
		pa, _ := toFloat64(a["price_per_unit"])
		pb, _ := toFloat64(b["price_per_unit"])
		return pa < pb
	case "price high to low", "price_desc":
		pa, _ := toFloat64(a["price_per_unit"])
		pb, _ := toFloat64(b["price_per_unit"])
		return pa > pb
	case "rating":
		ra, _ := toFloat64(a["rating"])
		rb, _ := toFloat64(b["rating"])
		if ra != rb {
			return ra > rb
		}
		return idLess(b["_id"], a["_id"])
	case "discount":
		da, _ := toFloat64(a["discount"])
		db, _ := toFloat64(b["discount"])
		if da != db {
			return da > db
		}
		return idLess(b["_id"], a["_id"])
	case "oldest":
		return idLess(a["_id"], b["_id"])
	}
	// newest / default
	return idLess(b["_id"], a["_id"])
}

func toFloat64(v interface{}) (float64, bool) {
	switch t := v.(type) {
	case float64:
		return t, true
	case float32:
		return float64(t), true
	case int32:
		return float64(t), true
	case int64:
		return float64(t), true
	case int:
		return float64(t), true
	default:
		return 0, false
	}
}

func mapProductToPublicListItem(c *gin.Context, p bson.M) (gin.H, bool) {
	pid, ok := objectIDFromProductDoc(p)
	if !ok {
		return nil, false
	}
	return gin.H{
		"Product id":          pid,
		"name":                p["name"],
		"short description":   p["short_descriptions"],
		"price per unit":      p["price_per_unit"],
		"unit":                p["unit"],
		"product catagory":    p["product_category"],
		"delivary category":   p["delivery_category"],
		"stock":               p["stock"],
		"brand name":          p["brand"],
		"photos":              p["photos"],
		"rating":              p["rating"],
		"discount":            p["discount"],
		"vender name":         "vendor name stub",
		"vender id":           p["vendor_id"],
		"iswishlisted":        CheckWishlist(c, pid),
		"category attributes": p["category_attributes"],
	}, true
}

// GetAllProducts handles /api/product/all
func GetAllProducts(c *gin.Context) {
	cat := c.Query("product category")
	if cat == "" {
		cat = c.PostForm("product category")
	}
	vendorIDStr := c.Query("vender id")
	if vendorIDStr == "" {
		vendorIDStr = c.Query("vendor id")
	}

	page, limit := parseProductPageLimit(c)
	skip := (page - 1) * limit
	sortKey := strings.TrimSpace(c.Query("sort by"))
	if sortKey == "" {
		sortKey = strings.TrimSpace(c.Query("sortBy"))
	}

	var preds []bson.M
	preds = append(preds, bson.M{"hidden": bson.M{"$ne": true}})
	requireApproved := true

	if cat != "" {
		if oid, err := primitive.ObjectIDFromHex(cat); err == nil {
			preds = append(preds, bson.M{"product_category": oid})
		} else {
			preds = append(preds, bson.M{"product_category": cat})
		}
	}
	delivery := strings.TrimSpace(c.Query("delivary category"))
	if delivery == "" {
		delivery = strings.TrimSpace(c.Query("delivery category"))
	}
	if delivery == "" {
		delivery = strings.TrimSpace(c.Query("deliveryCategory"))
	}
	if delivery != "" {
		preds = append(preds, bson.M{"delivery_category": delivery})
	}
	if vendorIDStr != "" {
		if vid, err := primitive.ObjectIDFromHex(vendorIDStr); err == nil {
			preds = append(preds, bson.M{"vendor_id": vid})
			// Logged-in vendor listing their own catalog: include pending/unapproved products.
			if selfID, ok := TryVendorHexIDFromBearer(c); ok && selfID == vendorIDStr {
				requireApproved = false
			}
		}
	}
	if requireApproved {
		preds = append(preds, bson.M{"approved": true})
	}

	if b := strings.TrimSpace(c.Query("brand name")); b != "" {
		esc := regexp.QuoteMeta(b)
		preds = append(preds, bson.M{"brand": bson.M{"$regex": esc, "$options": "i"}})
	}
	searchRaw := strings.TrimSpace(c.Query("search text"))
	if searchRaw == "" {
		searchRaw = strings.TrimSpace(c.PostForm("search text"))
	}
	fuzzySearch := searchRaw != ""
	priceRange := bson.M{}
	if mp := strings.TrimSpace(c.Query("min price")); mp != "" {
		if v, err := strconv.ParseFloat(mp, 64); err == nil {
			priceRange["$gte"] = v
		}
	}
	if xp := strings.TrimSpace(c.Query("max price")); xp != "" {
		if v, err := strconv.ParseFloat(xp, 64); err == nil {
			priceRange["$lte"] = v
		}
	}
	if len(priceRange) > 0 {
		preds = append(preds, bson.M{"price_per_unit": priceRange})
	}
	switch strings.TrimSpace(c.Query("stock_status")) {
	case "in_stock":
		preds = append(preds, bson.M{"stock": bson.M{"$gt": 0}})
	case "out_of_stock":
		preds = append(preds, bson.M{"stock": bson.M{"$lte": 0}})
	}
	if r := strings.TrimSpace(c.Query("rating")); r != "" {
		if v, err := strconv.ParseFloat(r, 64); err == nil {
			preds = append(preds, bson.M{"rating": bson.M{"$gte": v}})
		}
	}

	filter := bson.M{}
	if len(preds) == 1 {
		filter = preds[0]
	} else {
		filter["$and"] = preds
	}

	coll := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 12*time.Second)
	defer cancel()

	var results []bson.M
	var hasMore bool

	if fuzzySearch {
		const fuzzyCap int64 = 800
		opts := options.Find().SetLimit(fuzzyCap).SetSort(productSortBSON(sortKey))
		cursor, err := coll.Find(ctx, filter, opts)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
			return
		}
		_ = cursor.All(ctx, &results)

		tokens := strings.Fields(searchRaw)
		if len(tokens) == 0 {
			tokens = []string{searchRaw}
		}
		var scored []productDocScore
		for _, p := range results {
			name := bsonStringField(p["name"])
			brand := bsonStringField(p["brand"])
			short := bsonStringField(p["short_descriptions"])
			desc := bsonStringField(p["description"])
			hay := name + " " + brand + " " + short + " " + desc
			minRel := 1.0
			ok := true
			for _, tok := range tokens {
				if tok == "" {
					continue
				}
				sc := utils.SearchRelevanceScore(tok, hay, name, brand, short, desc)
				if sc < 0.5 {
					ok = false
					break
				}
				if sc < minRel {
					minRel = sc
				}
			}
			if !ok {
				continue
			}
			scored = append(scored, productDocScore{doc: p, rel: minRel})
		}
		sort.SliceStable(scored, func(i, j int) bool {
			if scored[i].rel != scored[j].rel {
				return scored[i].rel > scored[j].rel
			}
			return productDocLessByKey(scored[i].doc, scored[j].doc, sortKey)
		})
		results = make([]bson.M, len(scored))
		for i := range scored {
			results[i] = scored[i].doc
		}
		total := len(results)
		start := int(skip)
		if start > total {
			start = total
		}
		end := start + int(limit)
		if end > total {
			end = total
		}
		results = results[start:end]
		hasMore = int64(end) < int64(total)
	} else {
		opts := options.Find().
			SetSort(productSortBSON(sortKey)).
			SetSkip(skip).
			SetLimit(int64(limit))

		cursor, err := coll.Find(ctx, filter, opts)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
			return
		}
		_ = cursor.All(ctx, &results)
		hasMore = int64(len(results)) == limit
	}

	var mapped []gin.H
	for _, p := range results {
		row, ok := mapProductToPublicListItem(c, p)
		if !ok {
			continue
		}
		mapped = append(mapped, row)
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": mapped,
		"meta": gin.H{
			"page":     page,
			"limit":    limit,
			"count":    len(mapped),
			"has_more": hasMore,
		},
	})
}

// GetProductByID handles /api/product/id
func GetProductByID(c *gin.Context) {
	productIDStr := c.Query("product id")
	if productIDStr == "" {
		productIDStr = c.PostForm("product id")
	}

	productID, _ := primitive.ObjectIDFromHex(productIDStr)

	coll := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var p bson.M
	err := coll.FindOne(ctx, bson.M{"_id": productID, "hidden": bson.M{"$ne": true}}).Decode(&p)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "product not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": gin.H{
			"id":                   p["_id"],
			"Name":                 p["name"],
			"brand":                p["brand"],
			"description":          p["description"],
			"short description":    p["short_descriptions"],
			"price per unit":       p["price_per_unit"],
			"unit":                 p["unit"],
			"product catagory":     p["product_category"],
			"delivary category":    p["delivery_category"],
			"stock":                p["stock"],
			"brand name":           p["brand"],
			"photos":               p["photos"],
			"rating":               p["rating"],
			"discount":             p["discount"],
			"vender name":          "stub",
			"vender id":            p["vendor_id"],
			"iswishlisted":         CheckWishlist(c, productID),
			"category attributes":  p["category_attributes"],
			"reviews":              BuildReviewsPayload(ctx, productID),
		},
	})
}

// GetRecommendedProducts handles /api/product/recommended
func GetRecommendedProducts(c *gin.Context) {
	// Simple recommendation algorithm pulling latest unhidden products
	coll := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	opts := options.Find().SetLimit(15).SetSort(bson.M{"_id": -1})
	cursor, err := coll.Find(ctx, bson.M{"hidden": bson.M{"$ne": true}, "approved": true}, opts)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	var results []bson.M
	cursor.All(ctx, &results)

	var mapped []gin.H
	for _, p := range results {
		pid, ok := objectIDFromProductDoc(p)
		if !ok {
			continue
		}
		mapped = append(mapped, gin.H{
			"Product id":        pid,
			"name":              p["name"],
			"short description": p["short_descriptions"],
			"price per unit":    p["price_per_unit"],
			"unit":              p["unit"],
			"product catagory":  p["product_category"],
			"delivary category": p["delivery_category"],
			"stock":             p["stock"],
			"brand name":        p["brand"],
			"photos":            p["photos"],
			"rating":            p["rating"],
			"discount":          p["discount"],
			"vender name":       "vendor name stub",
			"vender id":         p["vendor_id"],
			"iswishlisted":      CheckWishlist(c, pid),
		})
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": mapped})
}
