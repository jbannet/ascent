# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# PROJECT CONTEXT FILES
Always check these files first to understand the codebase:
- `.codebase-index` - Complete project structure, file organization, and key components
- `.claude-index` - Architectural patterns, feature interactions, and development guidelines

# RULES
1. Query rules: use INVOKER, SET path, fully qualify tables. Query function parameters should start with "p_", declared variables with "v_". Save functions must use UPSERT

2. Code rules: Start with a plan and checking how the same task was completed before. NO defaults or fall-back values. No adding "FOR NOW" or temporary placeholder code: name the file and function, even if it does not yet exist. NO GUESSING. Get actual names from code. Do NOT assume. When done review your code against these rules and confirm. Use platform agnostic widgets in Flutter. Class, function, variable names should be VERY specific and clear about what they do. Write functions we know we need, not those we MAY need at some point. 

