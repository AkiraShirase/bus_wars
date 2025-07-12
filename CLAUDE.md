# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bus Wars is a 2D isometric game built with the Godot game engine. It combines bus driving simulation with visual novel elements and role-playing mechanics. The player operates a bus company, competing with other companies to transport passengers between bus stops across various city levels.

## Development Status

**Note**: This repository currently contains only the project documentation (README.md). The actual Godot project files, scripts, and assets have not yet been created.

## Game Architecture (Planned)

### Core Systems
- **Level System**: Large sandbox environments with roads, traffic lights, and bus stops
- **Route Management**: Players build bus routes that cannot intersect with routes from the same company
- **Competition System**: Multiple bus companies compete for passengers and routes
- **Passenger System**: Each passenger has properties (name, destination, danger level, faith)
- **Bus Customization**: Players build buses with configurable materials, engines, tires, and power sources

### Key Game Mechanics
- **Physics-based driving**: Vehicle handling based on weight, engine power, and tire materials
- **Route planning**: Strategic route building with company-specific restrictions
- **Passenger transport**: Multi-route journeys and company competition
- **Risk management**: Danger levels affect riot probability; faith affects passenger choice
- **City improvement**: Donation system to influence district safety and faith levels

## Power Sources & Technology Progression
The game features a unique progression system through different power source eras:
- Steam, Gas, Hydrogen, Battery (realistic technologies)
- Alien, Psychic, Chaos (fantastical late-game options)

## Development Commands

Since this is a Godot project that hasn't been initialized yet, typical development commands would include:
- **Godot Editor**: Open project in Godot editor for visual development
- **Export**: Use Godot's export system for building distributable versions
- **Version Control**: Standard git workflows for collaborative development

## When Starting Development

1. Initialize a new Godot project in this directory
2. Set up the basic scene structure for the isometric view
3. Create the core systems: level management, bus physics, route planning
4. Implement the passenger and company competition mechanics
5. Add the progression system with different power sources