# CLAUDE.md

# MANDATORY RULES 🛑 STOP - MANDATORY CHECKS - DO NOT PROCEED WITHOUT THESE 🛑
## BEFORE ANY RESPONSE:
  □ RUN: context-keeper agent 
  □ SAY: "Checked with context-keeper: [result]"
## IF YOU SKIP THESE → YOU FAILED
 # INSTANT FAIL CONDITIONS
  ❌ Started without context-keeper = FAILED
  ❌ Didn't say "Checked with context-keeper:
  [result]" = FAILED
  ❌ Used placeholder/temporary code = FAILED
  ❌ Guessed instead of checking = FAILED
  ❌ Assumed instead of verifying = FAILED

  # SPECIFIC RULES - NO EXCEPTIONS
  ## SQL/DATABASE:
  ✓ MUST: start with INVOKER, SET search_path, fully qualify tables
  ✓ MUST: prefix parameters with "p_", variables with "v_"  
  ✓ MUST: use UPSERT for saves
  ❌ NEVER: use default privileges or guess table names
  ## CODE:
  ✓ MUST: Check existing patterns FIRST (find where it was done before)
  ✓ MUST: Get actual names from code (grep/read, don't assume or make up names)
  ❌ NEVER: "// TODO", "// for now", placeholder code
  ❌ NEVER: Duplicate code that should be abstracted
  
  # THE ONLY ACCEPTABLE FLOW:
  1. Run context-keeper → Say "Checked with 
  context-keeper: [agreement]"
  2. Find existing pattern → Say "Found pattern 
  at: [file:line]"  
  3. Implement correctly → No shortcuts
  4. Verify → Say "Confirmed: follows all rules"
## END SPECIFIC RULES 

# PROJECT CONTEXT FILES
Always check these files first to understand the codebase:
- `.codebase-index` - Complete project structure, file organization, and key components
- `.claude-index` - Architectural patterns, feature interactions, and development guidelines
- /Users/jonathanbannet/MyProjects/fitness_app/feature_list - specifies what is a feature in the exercise matrix and profile feature list and what is part of the profile



