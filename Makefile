OBJ_VERSION=$(shell grep -Eo 'obj.version\s*=\s*"[^"]+"' init.lua | cut -d'"' -f2)
SHORT_GIT_SHA=$(shell git rev-parse --short HEAD)
TAG=$(OBJ_VERSION)
DIST_DIR=dist
SPOON_NAME=$(shell grep -Eo 'obj.name\s*=\s*"[^"]+"' init.lua | cut -d'"' -f2)

# Release target
release: clean_changelog changelog create_tag build_zip push_tag

# Clean the old changelog file
clean_changelog:
	@echo "Cleaning old CHANGELOG.md"
	@rm -f CHANGELOG.md

# Generate a simple changelog from git log
changelog:
	@echo "Generating CHANGELOG.md"
	@echo "## Version $(TAG)" > CHANGELOG.md
	@git log --pretty=format:"- %s" $(shell git describe --tags --abbrev=0)..HEAD >> CHANGELOG.md
	@echo "Changelog generated."

# Create a git tag
create_tag:
	@if git rev-parse "$(TAG)" >/dev/null 2>&1; then \
		TAG="$(TAG)-$(SHORT_GIT_SHA)"; \
	fi; \
	git tag -a $(TAG) -m "Release $(TAG)"
	@echo "Tag created: $(TAG)"

# Build the Spoon zip file
build_zip:
	@echo "Building zip file..."
	@rm -rf $(DIST_DIR)
	@mkdir -p $(DIST_DIR)
	@zip -r $(DIST_DIR)/$(SPOON_NAME).spoon.zip . -x ".git*" ".github*" "$(DIST_DIR)/*"
	@echo "Zip file created: $(DIST_DIR)/$(SPOON_NAME).spoon.zip"

# Push the code and tag
push_tag:
	@git push origin main
	@git push origin $(TAG)
	@echo "Code and tag pushed to GitHub: $(TAG)"
