SHELL := /bin/bash

.PHONY: help start stop bruno remove-bruno test-bruno

help:
	@echo "Available targets:"
	@echo "  help          - Show this help message"
	@echo "  start         - Start the MCP gateway server"
	@echo "  stop          - Stop the MCP gateway server"
	@echo "  install-bruno - Install Bruno CLI"
	@echo "  remove-bruno  - Remove Bruno CLI"
	@echo "  test-bruno    - Run Bruno tests in bruno-scenarios"

start:
	bash 01-start-gateway.sh

stop:
	bash 02-stop-gateway.sh

install-bruno:
	npm install -g @usebruno/cli --prefix ~/.local

remove-bruno:
	npm uninstall -g @usebruno/cli --prefix ~/.local

test-bruno:
	cd bruno-scenarios && bash run-bruno-tests.sh
