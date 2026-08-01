# Gatherly local workflow + mini-infra golden path ops.

set shell := ["/usr/bin/env", "bash", "-lc"]

PLATFORM_JUST := justfile_directory() + "/../mini-infra/platform/Justfile"
APP_NAME := "gatherly"
LAUNCHD_LABEL := "com.gatherly"
ENV_FILE := "${HOME}/.config/gatherly/env.runtime"
APP_PORT := "${GATHERLY_PROD_PORT:-4002}"
PHX_HOST := "${PHX_HOST:-gatherly.qingbo.us}"
DEPLOY_HOST := "${DEPLOY_HOST:-mini}"
DATABASE_NAME := "gatherly"

# Local development
setup:
	mise exec -- mix setup

dev:
	mise exec -- docker compose up -d db
	mise exec -- portless gatherly ./scripts/dev_with_tidewave_banner.sh

db-up:
	mise exec -- docker compose up -d db

db-down:
	mise exec -- docker compose down

test:
	mise exec -- docker compose up -d db
	mise exec -- mix test

format:
	mise exec -- mix format

check:
	mise exec -- docker compose up -d db
	mise exec -- mix precommit

precommit: check

# Production operations delegated to mini-infra.
_platform command:
	@ROOT_SRC={{justfile_directory()}} APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{APP_PORT}} PHX_HOST={{PHX_HOST}} DEPLOY_HOST={{DEPLOY_HOST}} DATABASE_NAME={{DATABASE_NAME}} just -f {{PLATFORM_JUST}} {{command}}

doctor: (_platform "doctor")

deploy: (_platform "deploy")

install: (_platform "install")

status: (_platform "status")

health: (_platform "health")

logs: (_platform "logs")

tail: (_platform "tail")

restart: (_platform "restart")

rollback: (_platform "rollback")

migrate: (_platform "migrate")
