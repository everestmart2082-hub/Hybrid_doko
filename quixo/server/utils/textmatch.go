package utils

import (
	"strings"
	"unicode/utf8"
)

// LevenshteinDistance computes edit distance between a and b.
func LevenshteinDistance(a, b string) int {
	if a == b {
		return 0
	}
	ra, rb := []rune(strings.ToLower(a)), []rune(strings.ToLower(b))
	if len(ra) == 0 {
		return len(rb)
	}
	if len(rb) == 0 {
		return len(ra)
	}
	prev := make([]int, len(rb)+1)
	for j := 0; j <= len(rb); j++ {
		prev[j] = j
	}
	for i := 1; i <= len(ra); i++ {
		cur := make([]int, len(rb)+1)
		cur[0] = i
		for j := 1; j <= len(rb); j++ {
			cost := 0
			if ra[i-1] != rb[j-1] {
				cost = 1
			}
			cur[j] = min3(prev[j]+1, cur[j-1]+1, prev[j-1]+cost)
		}
		prev = cur
	}
	return prev[len(rb)]
}

func min3(a, b, c int) int {
	if a <= b && a <= c {
		return a
	}
	if b <= c {
		return b
	}
	return c
}

// NormalizedSimilarity returns 0..1 (1 = identical). Uses Levenshtein / max rune length.
func NormalizedSimilarity(a, b string) float64 {
	a = strings.TrimSpace(a)
	b = strings.TrimSpace(b)
	if a == "" || b == "" {
		return 0
	}
	if strings.EqualFold(a, b) {
		return 1
	}
	d := LevenshteinDistance(a, b)
	maxLen := utf8.RuneCountInString(a)
	if lb := utf8.RuneCountInString(b); lb > maxLen {
		maxLen = lb
	}
	if maxLen == 0 {
		return 1
	}
	return 1.0 - float64(d)/float64(maxLen)
}

// IsSubsequenceFold returns true if every rune of query appears in text in order (case-insensitive).
func IsSubsequenceFold(query, text string) bool {
	q := []rune(strings.ToLower(strings.TrimSpace(query)))
	t := []rune(strings.ToLower(text))
	if len(q) == 0 {
		return true
	}
	qi := 0
	for _, ch := range t {
		if ch == q[qi] {
			qi++
			if qi == len(q) {
				return true
			}
		}
	}
	return false
}

// SearchRelevanceScore is best match of query against several haystacks (0..1).
func SearchRelevanceScore(query string, fields ...string) float64 {
	q := strings.TrimSpace(query)
	if q == "" {
		return 0
	}
	best := 0.0
	for _, f := range fields {
		f = strings.TrimSpace(f)
		if f == "" {
			continue
		}
		if sim := NormalizedSimilarity(q, f); sim > best {
			best = sim
		}
		// sliding windows on words
		words := strings.Fields(f)
		for _, w := range words {
			if sim := NormalizedSimilarity(q, w); sim > best {
				best = sim
			}
		}
		if IsSubsequenceFold(q, f) {
			if best < 0.55 {
				best = 0.55
			}
		}
	}
	return best
}
