MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
ALL_TARGETS := $(shell grep -E -o ^[0-9A-Za-z_-]+: $(MAKEFILE_LIST) | sed 's/://')
.PHONY: $(ALL_TARGETS)
.DEFAULT_GOAL := help
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null || echo "docker compose")

help: ## Show all available commands
	@echo "Oracle Database Installation & Testing Framework"
	@echo "================================================"
	@echo ""
	@echo "Using: $(DOCKER_COMPOSE)"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build Docker images
	@$(DOCKER_COMPOSE) build

build-ol7: ## Build Oracle Linux 7 image
	@$(DOCKER_COMPOSE) build oracle-linux-7

build-ol8: ## Build Oracle Linux 8 image
	@$(DOCKER_COMPOSE) build oracle-linux-8

clean: ## Clean up all containers, volumes, and networks
	@$(DOCKER_COMPOSE) down -v --remove-orphans

hadolint: ## Lint Dockerfiles
	@echo -e "\033[36m$@\033[0m"
	@hadolint Dockerfile.ol7
	@hadolint Dockerfile.ol8

lint: hadolint shellcheck shfmt ## Run all linting (hadolint, shellcheck, shfmt)

shellcheck: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@shellcheck **/*.sh

shfmt: ## Lint shell script formatting
	@echo -e "\033[36m$@\033[0m"
	@shfmt -l -d -i 2 -ci -bn **/*.sh

install-11.2-ol7: ## Install Oracle Database 11g R2 on Oracle Linux 7
	@$(DOCKER_COMPOSE) up -d oracle-linux-7
	@$(DOCKER_COMPOSE) exec oracle-linux-7 bash -c "cd /workspace/install-OracleDatabase11.2 && ./provision.sh"

install-12.1-ol7: ## Install Oracle Database 12c R1 on Oracle Linux 7
	@$(DOCKER_COMPOSE) up -d oracle-linux-7
	@$(DOCKER_COMPOSE) exec oracle-linux-7 bash -c "cd /workspace/install-OracleDatabase12.1 && ./provision.sh"

install-12.2-ol7: ## Install Oracle Database 12c R2 on Oracle Linux 7
	@$(DOCKER_COMPOSE) up -d oracle-linux-7
	@$(DOCKER_COMPOSE) exec oracle-linux-7 bash -c "cd /workspace/install-OracleDatabase12.2 && ./provision.sh"

install-18-ol7: ## Install Oracle Database 18c on Oracle Linux 7
	@$(DOCKER_COMPOSE) up -d oracle-linux-7
	@$(DOCKER_COMPOSE) exec oracle-linux-7 bash -c "cd /workspace/install-OracleDatabase18 && ./provision.sh"

install-19-ol7: ## Install Oracle Database 19c on Oracle Linux 7
	@$(DOCKER_COMPOSE) up -d oracle-linux-7
	@$(DOCKER_COMPOSE) exec oracle-linux-7 bash -c "cd /workspace/install-OracleDatabase19 && ./provision.sh"

install-19-ol8: ## Install Oracle Database 19c on Oracle Linux 8
	@$(DOCKER_COMPOSE) up -d oracle-linux-8
	@$(DOCKER_COMPOSE) exec oracle-linux-8 bash -c "cd /workspace/install-OracleDatabase19 && ./provision.sh"

install-19-arm-ol8: ## Install Oracle Database 19c ARM on Oracle Linux 8
	@$(DOCKER_COMPOSE) up -d oracle-linux-8
	@$(DOCKER_COMPOSE) exec oracle-linux-8 bash -c "cd /workspace/install-Oracle-Database-19c-for-LINUX-ARM && ./provision.sh"

install-21-ol8: ## Install Oracle Database 21c on Oracle Linux 8
	@$(DOCKER_COMPOSE) up -d oracle-linux-8
	@$(DOCKER_COMPOSE) exec oracle-linux-8 bash -c "cd /workspace/install-OracleDatabase21 && ./provision.sh"

test-11.2-ol7: ## Test Oracle Database 11g R2 on Oracle Linux 7
	@$(DOCKER_COMPOSE) up -d oracle-linux-7
	@$(DOCKER_COMPOSE) exec oracle-linux-7 sudo su - oracle -c "cd /workspace/install-OracleDatabase11.2 && /workspace/test-database.sh"

test-12.1-ol7: ## Test Oracle Database 12c R1 on Oracle Linux 7
	@$(DOCKER_COMPOSE) up -d oracle-linux-7
	@$(DOCKER_COMPOSE) exec oracle-linux-7 sudo su - oracle -c "cd /workspace/install-OracleDatabase12.1 && /workspace/test-database.sh"

test-12.2-ol7: ## Test Oracle Database 12c R2 on Oracle Linux 7
	@$(DOCKER_COMPOSE) up -d oracle-linux-7
	@$(DOCKER_COMPOSE) exec oracle-linux-7 sudo su - oracle -c "cd /workspace/install-OracleDatabase12.2 && /workspace/test-database.sh"

test-18-ol7: ## Test Oracle Database 18c on Oracle Linux 7
	@$(DOCKER_COMPOSE) up -d oracle-linux-7
	@$(DOCKER_COMPOSE) exec oracle-linux-7 sudo su - oracle -c "cd /workspace/install-OracleDatabase18 && /workspace/test-database.sh"

test-19-ol7: ## Test Oracle Database 19c on Oracle Linux 7
	@$(DOCKER_COMPOSE) up -d oracle-linux-7
	@$(DOCKER_COMPOSE) exec oracle-linux-7 sudo su - oracle -c "cd /workspace/install-OracleDatabase19 && /workspace/test-database.sh"

test-19-ol8: ## Test Oracle Database 19c on Oracle Linux 8
	@$(DOCKER_COMPOSE) up -d oracle-linux-8
	@$(DOCKER_COMPOSE) exec oracle-linux-8 sudo su - oracle -c "cd /workspace/install-OracleDatabase19 && /workspace/test-database.sh"

test-19-arm-ol8: ## Test Oracle Database 19c ARM on Oracle Linux 8
	@$(DOCKER_COMPOSE) up -d oracle-linux-8
	@$(DOCKER_COMPOSE) exec oracle-linux-8 sudo su - oracle -c "cd /workspace/install-Oracle-Database-19c-for-LINUX-ARM && /workspace/test-database.sh"

test-21-ol8: ## Test Oracle Database 21c on Oracle Linux 8
	@$(DOCKER_COMPOSE) up -d oracle-linux-8
	@$(DOCKER_COMPOSE) exec oracle-linux-8 sudo su - oracle -c "cd /workspace/install-OracleDatabase21 && /workspace/test-database.sh"

shell-ol7: ## Enter Oracle Linux 7 container shell
	@$(DOCKER_COMPOSE) up -d oracle-linux-7
	@$(DOCKER_COMPOSE) exec oracle-linux-7 /bin/bash

shell-ol8: ## Enter Oracle Linux 8 container shell
	@$(DOCKER_COMPOSE) up -d oracle-linux-8
	@$(DOCKER_COMPOSE) exec oracle-linux-8 /bin/bash
