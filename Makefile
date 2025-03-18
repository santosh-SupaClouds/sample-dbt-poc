.PHONY: setup env install deps debug compile run test docs clean

# Variables
VENV := dbt-env
PYTHON := python3
PIP := $(VENV)/bin/pip
DBT := $(VENV)/bin/dbt
TARGET := dev

setup: $(VENV) env install deps

# Create virtual environment
$(VENV):
	$(PYTHON) -m venv $(VENV)

# Set up environment file
env:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo ".env file created. Please update it with your credentials."; \
	else \
		echo ".env file already exists."; \
	fi

# Install dependencies
install: $(VENV)
	. $(VENV)/bin/activate && $(PIP) install --upgrade pip
	. $(VENV)/bin/activate && $(PIP) install -r requirements.txt

# Install dbt packages
deps: $(VENV)
	. $(VENV)/bin/activate && $(DBT) deps

# Debug configuration
debug: $(VENV)
	. $(VENV)/bin/activate && $(DBT) debug

# Compile models
compile: $(VENV)
	. $(VENV)/bin/activate && $(DBT) compile

# Run models
run: $(VENV)
	. $(VENV)/bin/activate && $(DBT) run --target $(TARGET)

# Run specific model or models
run-select: $(VENV)
	@if [ -z "$(MODELS)" ]; then \
		echo "Usage: make run-select MODELS=model_name"; \
	else \
		. $(VENV)/bin/activate && $(DBT) run --select $(MODELS) --target $(TARGET); \
	fi

# Run tests
test: $(VENV)
	. $(VENV)/bin/activate && $(DBT) test --target $(TARGET)

# Generate documentation
docs: $(VENV)
	. $(VENV)/bin/activate && $(DBT) docs generate
	. $(VENV)/bin/activate && $(DBT) docs serve

# Clean build artifacts
clean:
	rm -rf target/
	rm -rf dbt_packages/
	rm -rf logs/

# Full clean including virtual environment
clean-all: clean
	rm -rf $(VENV)/

# Create project structure
create-dirs:
	mkdir -p models/{staging,intermediate,marts}
	mkdir -p {macros,tests,seeds,snapshots}

# Set up profiles.yml
setup-profiles:
	mkdir -p ~/.dbt
	@if [ ! -f ~/.dbt/profiles.yml ]; then \
		ln -s $(PWD)/profiles.yml ~/.dbt/profiles.yml; \
		echo "~/.dbt/profiles.yml created."; \
	else \
		echo "~/.dbt/profiles.yml already exists. Manually link if needed."; \
	fi

# Help
help:
	@echo "Available targets:"
	@echo "  setup          - Set up complete environment"
	@echo "  env            - Create .env file from template"
	@echo "  install        - Install Python dependencies"
	@echo "  deps           - Install dbt packages"
	@echo "  debug          - Debug dbt connection"
	@echo "  compile        - Compile dbt models"
	@echo "  run            - Run all dbt models"
	@echo "  run-select     - Run specific models (make run-select MODELS=model_name)"
	@echo "  test           - Run dbt tests"
	@echo "  docs           - Generate and serve dbt docs"
	@echo "  clean          - Clean dbt artifacts"
	@echo "  clean-all      - Clean all artifacts including virtual environment"
	@echo "  create-dirs    - Create project directories"
	@echo "  setup-profiles - Set up profiles.yml in ~/.dbt/"