Design's approved to build, with the changes below. The first three refine the daily
flow; the fourth adds a second mode.

1. Don't log hours through the general update-issue call. Use the MCP's dedicated
   worklog / add-worklog operation instead — it does only that and returns a worklog
   id. The general update-issue call shouldn't be used anywhere in this command,
   since it's the one that could carry other field changes. Confirm the MCP actually
   exposes a dedicated worklog operation before building; if it doesn't, stop and
   tell me rather than working around it.

2. The "not Done" ticket list has a gap: if I've already moved a ticket to Done and
   then go to log hours on it, it won't appear and you'll refuse it. Add a fallback
   where I can type a ticket key when it's not in the list — but still verify that key
   is assigned to me before drafting, and refuse if it isn't.

3. Keep assignee = currentUser() as the definition of "mine" — that's intended. When
   you show proposed hours, present them as a rough figure I confirm or edit, not as
   something precise.

4. Add a second mode: backfill missed worklogs. Sometimes I've forgotten to log time
   on a ticket for one or more past days and need to add just the hours after the
   fact — no comment. In this mode:
   - I give you the ticket and a set of date + hours entries (one or several days,
     e.g. "Oct 20 = 4h, Oct 21 = 6h").
   - You set each worklog's date to the date I give, not today (Jira worklogs carry a
     start date — verify the MCP lets you set it; if it can't, stop and tell me).
   - Log time ONLY in this mode — never add a comment.
   - Same guardrails apply exactly as in the daily flow: my tickets only (verify the
     key is assigned to me, including the type-a-key fallback since a missed ticket
     may already be Done), the dedicated worklog operation only, never touch any other
     field/status/transition/assignee/label/sprint, and nothing posts until I approve.
   - Show me the full list — ticket, each date, each hours figure — in one preview,
     and wait for my explicit yes before posting any of it. Let me edit any line or
     cancel.
   - Warn me (don't block) if the local log already shows a worklog on that ticket for
     the same date, and append each backfilled entry to the local log like the daily
     ones.

Everything else stays as designed: two-writes-only in the daily flow, draft-from-
session with fallback-to-asking, double-log guard, local audit log.
