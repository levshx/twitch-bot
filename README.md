# twitch-bot

[![Build](https://github.com/levshx/twitch-bot/actions/workflows/build_ci.yml/badge.svg)](https://github.com/levshx/twitch-bot/actions/workflows/build_ci.yml)
[![Docs](https://github.com/levshx/twitch-bot/actions/workflows/docs_ci.yml/badge.svg)](https://github.com/levshx/twitch-bot/actions/workflows/docs_ci.yml)

To build using [Nimble](https://github.com/nim-lang/nimble) run the following:

Before build, create oAuth key and write him in `bin\oauth.key`

```
$ cd twitch-bot
$ nimble build
```

## example
```nim
import core/botcore
import os, strutils, sequtils

var
  BotNick = "levshxbot"
  OAuthKey = readFile(getAppDir() / "oauth_twitch.key") # create file with bot.exe > oauth.key 
  Chanel = "levshx"
  bot = newTwitchBot(BotNick, OAuthKey, Chanel)


proc helloCallback(nick: string, args: seq[string]) =
  bot.sendMessage("@"&nick&" HELLO!!!")

proc main(): void =
  var hello: Trigger_Command
  hello.reg = re"hello"
  hello.callback = helpCallback  

  bot.triggers.command.add(hello)
  bot.logEnable(true)

  while not bot.connect():
    bot.logLine("try reconnect")

  while true:
    bot.step()

main()
```
