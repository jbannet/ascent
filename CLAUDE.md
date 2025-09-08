# CLAUDE.md

# RULES
Before starting ANY task, invoke the context-keeper agent to establish context. Check with it after each major step.
When you have checked in with the context-keeper agent, say that so I know you are following this rule.
1. Query rules: use INVOKER, SET path, fully qualify tables. Query function parameters should start with "p_", declared variables with "v_". Save functions must use UPSERT
2. Code rules: Start with a plan and checking how the same task was completed before. NO defaults or fall-backs. No adding "FOR NOW" or temporary placeholder code. NO GUESSING. Get actual names from code. Do NOT assume. When done review your code against these rules and confirm.


# PROJECT CONTEXT FILES
Always check these files first to understand the codebase:
- `.codebase-index` - Complete project structure, file organization, and key components
- `.claude-index` - Architectural patterns, feature interactions, and development guidelines
- /Users/jonathanbannet/MyProjects/fitness_app/feature_list - specifies what is a feature in the exercise matrix and profile feature list and what is part of the profile



