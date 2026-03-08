# Agent Instructions for NLE

**CRITICAL: MANDATORY SANDBOX CHECK**
Before performing any actions, the agent MUST check if it is running inside a Docker container (e.g., by checking for the existence of `/.dockerenv`).
- If **NOT** in a container: The agent MUST immediately stop and ask the user to run `./scripts/gemini-sandbox.sh` to create a development sandbox.
- If **IN** a container: The agent may proceed with the tasks.

**CRITICAL: INSTRUCTION INTEGRITY**
The agent MUST alert the user to any contradictory or confusing instructions. If the agent encounters instructions that conflict with each other or are unclear, it MUST stop all work immediately and seek clarification. No further work should be performed until the confusion or contradictions have been fully addressed and resolved by the user.

**CRITICAL: PRIVILEGE RESTRICTION**
The agent MUST NEVER run or offer to run any command using `sudo`. The agent MUST NEVER attempt to change the current user to `root` or perform any actions that require root privileges. All operations must be performed with the current user's permissions.

---

# NetHack Learning Environment (NLE) - Project Summary

The NetHack Learning Environment (NLE) is a high-performance reinforcement learning environment based on the classic roguelike game **NetHack**. It is designed for AI research, providing a complex, procedural, and challenging environment for RL agents.

## Core Components

### 1. NetHack Engine (C)
The project contains a slightly modified version of the NetHack source code (located in `src/`, `include/`, `dat/`, etc.). These modifications allow the game to be controlled programmatically and to extract internal state efficiently.

### 2. RL Windowing System (C++)
Located in `win/rl/`, this is a custom NetHack windowing system (`winrl.cc`). Unlike standard TTY or graphical interfaces, it captures the game state (glyphs, messages, statistics, inventory) and provides it as structured data.
- **`winrl.cc`**: Implements the `window_procs` interface for NetHack, intercepting display updates.
- **`pynethack.cc`**: Provides Python bindings using `pybind11` to interact with the NetHack engine.

### 3. Gymnasium Integration (Python)
The core Python logic resides in `nle/env/`, which implements the `gymnasium.Env` interface.
- **`base.py`**: Defines the `NLE` class, which handles the observation and action spaces. Observations include 2D arrays of glyphs, characters, colors, as well as bottom-line statistics (`blstats`) and inventory information.
- **`tasks.py`**: Defines specific RL tasks like `NetHackScore`, `NetHackStaircase`, `NetHackGold`, etc., with custom reward functions.

### 4. Low-level Integration (`src/nle.c`)
Handles the low-level lifecycle of the NetHack process, including memory management and synchronization between the Python/C++ layer and the NetHack C engine. It uses a terminal emulator (`tmt`) to capture and process TTY output.

## Key Features

- **Performance**: Capable of running thousands of steps per second, significantly faster than traditional NetHack interfaces.
- **Rich Observations**: Provides both symbolic (glyphs, object classes) and "pixel-like" (characters, colors) representations of the game state.
- **Task Variety**: Includes a range of tasks from simple navigation to full game play, allowing for incremental research.
- **Dataset Support**: Tools for recording and replaying games (`ttyrec`) and working with NetHack datasets (`nle/dataset/`).
- **Customizability**: Supports custom seeds, character configurations, and NetHack options.

## Project Structure Highlights

- `nle/env/`: Core Gymnasium environment implementation.
- `nle/nethack/`: NetHack-specific constants, actions, and utilities.
- `win/rl/`: C++ glue code and RL-specific windowing system.
- `src/nle.c`: Integration layer between NetHack and NLE.
- `dat/`: NetHack data files (dungeons, monsters, items).
- `pyproject.toml`: Build configuration and dependencies (`gymnasium`, `pybind11`, `numpy`).

---

## Sandboxed Execution (Docker)

To run interactions in a secure sandbox, use the provided `.devcontainer/Dockerfile`.

### 1. Build the Sandbox
```bash
docker build -t nle-sandbox -f .devcontainer/Dockerfile .
```

### 2. Run the Sandbox
Forward your `GEMINI_API_KEY` at runtime to avoid hardcoding it:
```bash
docker run -it --rm \
  -v "$(pwd):/workspace" \
  -e GEMINI_API_KEY=$GEMINI_API_KEY \
  nle-sandbox
```

Once inside the container, you can start the agent with:
```bash
gemini
```

---

# Agent Instructions for NLE

This project uses `uv` to manage Python packages and environments.

## Python Commands
Always use `uv` to run Python commands.

**Mandatory Workflow**: After making any code changes, you MUST run the linter and tests to ensure no regressions or style violations were introduced.

- **Running Tests**: `uv run pytest`
- **Linting**: `uv run ruff check`
- **Formatting**: `uv run ruff format`
- **Running Scripts**: `uv run python -m nle.scripts.play` (or other scripts)

## Project Collaboration Questions

1. **Language Balance**: When a feature requires changes in both C/C++ (the engine/windowing) and Python (the environment), should I prioritize the C-level implementation for performance or the Python-level for accessibility?
2. **Testing Strategy**: Should I always run the full suite (`uv run pytest`) for every change, or is it preferred to run targeted tests first to save time?
3. **C Code Modifications**: The NetHack C code is highly specific. Should I strictly avoid refactoring existing NetHack code unless it's directly necessary for NLE functionality?
4. **Observation Space Changes**: If I need to add a new observation, how should I handle potential breaking changes for downstream RL agents that expect a specific observation dictionary?
5. **Dependency Management**: Before adding a new Python dependency via `uv add`, should I always check for an existing C/C++ equivalent already used in the project?
6. **Code Style**: For C++, should I strictly follow the `.clang-format` or defer to the surrounding style in `win/rl/`?
7. **Task Definitions**: When adding new RL tasks to `nle/env/tasks.py`, should I always provide a corresponding benchmark or example script?
8. **Logging vs. Exceptions**: NetHack has its own internal logging/error handling. Should I wrap C-level errors in Python exceptions, or preserve the original NetHack behavior?
9. **Documentation**: Should I update `AgentSummary.md` or other high-level docs for every architectural change, or only for major feature releases?
10. **Hardware Acceleration**: For features involving `torch` (optional-dependency), should I assume the presence of a GPU during development and testing?
