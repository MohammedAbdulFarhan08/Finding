In my VS Code Claude session, /mcp shows only plugin:playwright:playwright (Failed)
and no sap-jira — but here in the terminal, sap-jira is user-scoped and connected.
Both should share ~/.claude.json. Figure out why the VS Code session can't see the
user-scoped sap-jira server: confirm which config each is reading, whether they're the
same Claude Code install/version, and whether anything is overriding MCP config for
the VS Code workspace. Tell me what you find and the fix — don't change anything or
touch Jira until I approve.
