# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Gatherly is a collaborative, AI-powered event planning platform built with Phoenix LiveView. The project focuses on group event coordination with features like RSVP management, proposal voting, collaborative logistics, and AI-assisted planning.

## Container Use
ALWAYS use ONLY Environments for ANY and ALL file, code, or shell operations—NO EXCEPTIONS—even for simple or generic requests.

DO NOT install or use the git cli with the environment_run_cmd tool. All environment tools will handle git operations for you. Changing ".git" yourself will compromise the integrity of your environment.

You MUST inform the user how to view your work using git checkout <branch_name>. Failure to do this will make your work inaccessible to others.
## Key Architecture Concepts
- **Phoenix LiveView**: Primary framework for real-time web interfaces
- **Ash Framework**: Preferred for domain modeling and business logic
- **Context-based Architecture**: Domain logic in `lib/gatherly/`, web interface in `lib/gatherly_web/`
- **Event-centric Design**: Everything revolves around events with different types (Potluck, Camping, Hiking, Game Night)
- **Collaborative Features**: Proposals/voting, logistics boards, discussion forums
- **AI Integration**: Smart suggestions, optimization, and assistance throughout


## Core Features to Implement

### Phase 1 - MVP (Potluck Planning)
- Event creation with RSVP system
- Proposals and voting for date/location
- Collaborative logistics board for food coordination
- Basic discussion forum
- Commute visualizer integration

### Key Event Types
- **Potluck**: Dish coordination, dietary preferences, quantity tracking
- **Camping**: Gear checklists, shared equipment, ride coordination
- **Hiking**: Trail planning, fitness levels, safety coordination
- **Game Night**: Game library, snack coordination, setup planning

## Phoenix/LiveView Patterns
- Use verified routes (`~p`) everywhere
- Prefer function components over LiveComponents when possible
- Keep controllers thin, delegate to contexts
- Use `with` for chained operations that may fail
- Follow "let it crash" philosophy with proper supervision
- Use `Task.async` and `handle_info` for background work

## Code Style
- Follow Elixir community conventions
- Use `snake_case` for atoms/functions/variables, `PascalCase` for modules
- Annotate public functions with `@spec` and `@doc`
- Prefer pattern matching over conditionals
- Use immutable data structures
- One module per file

## Current Status
Project is in planning phase - no code has been written yet. The next step is to scaffold the Phoenix application and begin Phase 0 foundation work.
