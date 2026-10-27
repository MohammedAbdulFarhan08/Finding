The /jira-log and /jira-backfill commands are global (~/.claude/commands), but the
sap-jira MCP they depend on isn't available in every session — it's registered at the
default local scope, so it only loads in the directory where we built and tested this.
These commands are meant to run from any session.

Check the current scope with `claude mcp get sap-jira`, then re-register the Jira MCP
at user scope so it's available in all my sessions regardless of working directory.
Keep the exact same endpoint and config — don't change anything else. Tell me whether
I need to re-authenticate afterward and walk me through it if so. Don't improvise any
Jira write in the meantime.
