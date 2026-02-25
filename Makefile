SHELL := /bin/bash

.PHONY: help start stop

help:
	@echo "Available targets:"
	@echo "  help   - Show this help message"
	@echo "  start  - Start the MCP gateway server"
	@echo "  stop   - Stop the MCP gateway server"

start:
	bash 01-start-gateway.sh

stop:
	bash 02-stop-gateway.sh
