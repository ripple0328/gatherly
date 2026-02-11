# Gatherly — thin wrapper around platform ops Justfile

set shell := ["/usr/bin/env", "bash", "-lc"]

PLATFORM_JUST := "/Users/qingbo/Projects/Personal/platform/Justfile"
APP_NAME := "gatherly"
LAUNCHD_LABEL := "com.gatherly"
ENV_FILE := "${HOME}/.config/gatherly/.envrc.worker"
PORT := "${PORT:-4002}"
PHX_HOST := "${PHX_HOST:-gatherly.qingbo.us}"

status:
	@APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{PLATFORM_JUST}} status

health:
	@APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{PLATFORM_JUST}} health

logs:
	@APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{PLATFORM_JUST}} logs

restart:
	@APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{PLATFORM_JUST}} restart

migrate:
	@APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{PLATFORM_JUST}} migrate

deploy-mini:
	@APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{PLATFORM_JUST}} deploy-mini

deploy-mini-local:
	@APP_NAME={{APP_NAME}} LAUNCHD_LABEL={{LAUNCHD_LABEL}} ENV_FILE={{ENV_FILE}} PORT={{PORT}} PHX_HOST={{PHX_HOST}} just -f {{PLATFORM_JUST}} deploy-mini-local

deploy: deploy-mini
