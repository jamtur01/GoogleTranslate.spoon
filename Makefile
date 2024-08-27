OBJ_VERSION=$(shell grep -Eo 'obj.version\s*=\s*"[^"]+"' init.lua | cut -d'"' -f2)
SHORT_GIT_SHA=$(shell git rev-parse --short HEAD)
BASE_TAG=v$(OBJ_VERSION)
TAG=$(BASE_TAG)

# Release target
release: clean_changelog changelog check_tag_exists create_tag push_tag

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
	@git add CHANGELOG.md
	@git commit -m "Update CHANGELOG.md for release $(TAG)"

# Check if the base tag exists, and update TAG if necessary
check_tag_exists:
	@if git rev-parse "$(BASE_TAG)" >/dev/null 2>&1; then \
		echo "Tag $(BASE_TAG) already exists, updating tag to include SHA"; \
		echo "Updated tag: $(BASE_TAG)-$(SHORT_GIT_SHA)"; \
		$(eval TAG=$(BASE_TAG)-$(SHORT_GIT_SHA)); \
	fi

# Create a git tag with the updated TAG
create_tag:
	@git tag -a $(TAG) -m "Release $(TAG)"
	@echo "Tag created: $(TAG)"

# Push the code and tag
push_tag:
	@git push origin main
	@git push origin $(TAG)
	@echo "Code and tag pushed to GitHub: $(TAG)"
