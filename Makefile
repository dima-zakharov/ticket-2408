SHELL := /bin/bash

.PHONY: help start stop start-ci stop-ci install-bruno remove-bruno test-bruno test

help:
	@echo "Available targets:"
	@echo "  help          - Show this help message"
	@echo "  start         - Start the MCP gateway server (tmux)"
	@echo "  stop          - Stop the MCP gateway server (tmux)"
	@echo "  start-ci      - Start the MCP gateway server (CI-friendly, background)"
	@echo "  stop-ci       - Stop the MCP gateway server (CI-friendly)"
	@echo "  install-bruno - Install Bruno CLI"
	@echo "  remove-bruno  - Remove Bruno CLI"
	@echo "  test-bruno    - Run Bruno tests in bruno-scenarios"
	@echo "  test          - Run full test suite (start server, run tests, stop server)"

start:
	bash 01-start-gateway.sh

stop:
	bash 02-stop-gateway.sh

start-ci:
	bash 03-start-gateway-ci.sh

stop-ci:
	bash 04-stop-gateway-ci.sh

install-bruno:
	npm install -g @usebruno/cli --prefix ~/.local

remove-bruno:
	npm uninstall -g @usebruno/cli --prefix ~/.local

test-bruno:
	cd bruno-scenarios && bash run-bruno-tests.sh

test: start-ci
	@echo "Running tests..."
	$(MAKE) test-bruno; \
	$(MAKE) stop-ci
