package installer

import (
	"os"
	"path"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetOrCreateUuidCreatesAndReuses(t *testing.T) {
	file := path.Join(t.TempDir(), ".secret")

	first, err := getOrCreateUuid(file)
	assert.NoError(t, err)
	assert.NotEmpty(t, first)

	content, err := os.ReadFile(file)
	assert.NoError(t, err)
	assert.Equal(t, first, string(content))

	second, err := getOrCreateUuid(file)
	assert.NoError(t, err)
	assert.Equal(t, first, second)
}
