You are a senior AI automation engineer. I want you to build me an agent that lives
here in Claude Code and handles my daily Jira updates — logging hours and adding a
comment on MY tickets only, with me approving every single write before it happens.

CONTEXT / FACTS
- I work in Claude Code day to day (not Claude Chat), so the agent should live here
  and be driven from my normal Claude Code sessions.
- A Jira MCP server is already available to you — use it for all Jira access. Don't
  build your own Jira client or store credentials anywhere.
- I will share a team document that describes exactly how we log worklogs/hours and
  format updates on our tickets. Follow that convention precisely — read it before
  you design anything.
- The "what did I do today" content comes from my current Claude Code session (what
  you and I actually worked on) and/or what I tell the agent directly. The agent
  drafts the comment from that real work — it must never invent or pad work.

WHAT IT MUST DO
- Connect to Jira through the MCP server and work out which tickets are mine. Confirm
  with me whether "mine" means assigned-to-me, reported-by-me, or both.
- Run ONLY when I explicitly ask it to — never on a schedule, never on its own.
- For a specific ticket, draft a daily update: a comment + a proposed number of hours.
- ALWAYS show me a preview first — the exact ticket key, the full comment text, and
  the hours — and wait for my explicit approval before writing anything to Jira.
- Let me edit the comment or the hours in that preview before it posts.
- Only after I approve, post the comment and log the worklog, in the team doc's format.

HARD GUARDRAILS (never cross these)
- Only ever write to tickets that are mine. Refuse anything else, even if I ask.
- The ONLY two write actions allowed are: add a comment, and log work hours.
- Never touch the title, description, status, assignee, priority, labels, sprint, or
  any other field. Treat everything except the comment and the worklog as read-only.
- Nothing reaches Jira without my explicit yes in that moment. No silent writes, no
  batching, no "I'll just also update...".

HOW I WANT YOU TO WORK
- Investigate first: inspect what the Jira MCP server can actually do, read the team
  doc I give you, understand how comments and worklogs really behave on our instance,
  and assess the blast radius of each write action.
- Then propose a design to me before building anything — how I'll invoke the agent,
  what the approval flow looks like, how it picks the ticket, and how it pulls the
  day's work from our session or my input.
- Build only after I approve the design.
- You have a free hand to add sensible things that make this safer or more useful —
  e.g. a dry-run/preview mode, a small local log of what got posted each day, a guard
  that stops me double-logging the same ticket on the same day, an easy way to pick
  the ticket, a clean trigger phrase or command. Suggest them; don't over-engineer.
- Keep it simple enough that I can run the whole thing with one command and a yes/no,
  without needing to understand the internals.
