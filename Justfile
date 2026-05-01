# Gatherly local workflow + mini-infra golden path ops.

set shell := ["/usr/bin/env", "bash", "-lc"]

INFRA_JUST    := "/Users/qingbo/Projects/Personal/mini-infra/platform/Justfile"
APP_NAME      := "gatherly"
LAUNCHD_LABEL := "com.gatherly"
ENV_FILE      := "${HOME}/.config/gatherly/env.runtime"
PORT          := "4002"
PHX_HOST      := "gatherly.qingbo.us"

# Local development
setup:
	mise x -- mix setup

dev:
	mise x -- docker compose up -d db
	mise x -- portless gatherly ./scripts/dev_with_tidewave_banner.sh

db-up:
	mise x -- docker compose up -d db

db-down:
	mise x -- docker compose down

test:
	mise x -- docker compose up -d db
	mise x -- mix test

format:
	mise x -- mix format

precommit:
	mise x -- docker compose up -d db
	mise x -- mix precommit

# Production operations delegated to mini-infra.
deploy:
	APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{INFRA_JUST}} deploy

install:
	APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{INFRA_JUST}} install

status:
	APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{INFRA_JUST}} status

health:
	APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{INFRA_JUST}} health

logs:
	APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{INFRA_JUST}} logs

tail:
	APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{INFRA_JUST}} tail

restart:
	APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{INFRA_JUST}} restart

rollback:
	APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{INFRA_JUST}} rollback

migrate:
	APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{INFRA_JUST}} migrate
