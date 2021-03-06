Cheatah is cheat sheet manager working on Slack.

## What he can do is

Cheatah keeps your notes like cheat sheets. We often forget how to use tools, API, coding rules, kinds of format...

But, we will never lose these kind of tips because we can get them only asking him.

There are only 3 words what you should use. *Open, Save, Delete* only.

```
open (file name)
save (file name)
delete (file name)
```

He follows the favors below anytime.

```
:bye/
:stop/
:cancel/
  -> He stops all conversation with you.
```

## How to run

Cheatah is powered by [Botkit](https://github.com/howdyai/botkit)

#### About API

It is necessary to prepare Slack API token.
Create a bot user in your team from [this page](https://my.slack.com/services/new/bot).

This app import token as `SLACK_BOT_TOKEN_CHEATAH`.
After you get token, set it as environment variable.

#### Additional

Files under `./data/cheatah` are just examples.