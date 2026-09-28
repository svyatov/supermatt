# Driving a web app

Use the browser tool this session has: Chrome DevTools MCP, Claude in Chrome, Playwright MCP, or the host's own. When the repo already depends on Playwright or Cypress, a scratch script in `$DIR` that uses it works too. With neither, every browser scenario is **blocked**: name the tool to connect, and QA the rest.

- **Start** the dev server as a background process, wait until its URL answers, and open it in a new tab.
- **Act** through the page as a user does: click, type into fields, pick options, submit, go back, reload. Find elements from the page's accessibility snapshot, and take a screenshot to see the layout.
- **Check** after each action: the text and state the scenario expects, the console for errors, and the network log for failed requests.
- **Capture** a screenshot of each visual result into `$DIR`, so the report can cite it and a pull request can show it as evidence.
- **Stop** by closing the tabs you opened and stopping the dev server.

Unhappy paths a web app adds:

- A form submitted empty, with invalid values, and twice in a row.
- A reload or the back button midway through a flow.
- The flow done by keyboard alone: Tab through it, Enter to submit.
- A narrow viewport (375 px wide) when the change touches layout.
