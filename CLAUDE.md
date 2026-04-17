# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A digital Texas Hold'em poker game following standard rules, including blind bets, betting rounds, community cards and hand ranking. It supports basic AI opponents, interactive UI, chip betting and game result settlement.

The main scene (`res://scenes/main.tscn`) contains all manager nodes. Cards are instantiated from `res://scenes/Card.tscn` when drawn.

## Architecture

详细架构说明已移至 [docs/architecture.md](docs/architecture.md)。

## Common Development Tasks

常见开发任务说明已移至 [docs/development-tasks.md](docs/development-tasks.md)。

## Notes

- 实时诊断、悬停信息、首选定义、完成信息等调用gdscript-lsp
- 调用MCP时，start和debug你都自动，stop需要我手动同意
- 其他备注说明已移至 [docs/notes.md](docs/notes.md)。
