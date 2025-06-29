NAME = "pdq"

DOCKER = docker
REQUIREMENTS = pyproject.toml
SOURCE = src/**

IMAGE_TAGS = latest
IMAGES = $(foreach tag,$(IMAGE_TAGS),$(NAME):$(tag))

# Runtime containers
CONTAINER_NAME = $(NAME)
TEST_CONTAINER_NAME = debug-$(NAME)
TOOL_CONTAINER_NAME = tools-$(NAME)


default: build
.PHONY: FORCE clean build test debug format lint typecheck checks activate cleanvenv venv
FORCE:

# Utility rules
# -------------

clean:
	docker rmi $(IMAGES) || true

# -- Vanilla Build Rules --
build: Dockerfile $(SOURCE)
	$(DOCKER) build \
		--tag $(NAME):latest \
		.

run: build
	docker run --rm \
		--publish=5000:5000 \
		--name="$(CONTAINER_NAME)" \
		$(NAME):latest


# -- Testing Build Rules --
test:
	uv run pytest


# -- Tools build rules --
format:
	uvx ruff check

typecheck:
	uvx mypy .

checks: format typecheck
