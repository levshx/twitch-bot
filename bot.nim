import core/botcore
import os, strutils

var
  BotNick = "levshxbot"
  OAuthKey = readFile(getAppDir() / "oauth.key") # create file with bot.exe > oauth.key 
  Chanel = "levshx"
  badwords_answers = readFile(getAppDir() / "badwordsNotice.txt").splitLines()


var bot = newTwitchBot(BotNick, OAuthKey, Chanel)

proc help(nick: string, args: seq[string]) =
  bot.sendMessage("@"&nick&", комманды тут: t.ly/23de")

proc getSocialRating(nick: string): int =
  return nick.len

proc rating(nick: string, args: seq[string]) = 
  bot.sendMessage("@"&nick&", очки социального рейтинга: "& $(getSocialRating(nick)*10))

proc badwordCallback(nick:string) =
  bot.sendMessage("@" & nick & ", " & badwords_answers[rand(0..badwords_answers.len-1)])
     
proc main(): void =
  var helper: Trigger_Command
  helper.reg = re"^ *!help *$"
  helper.callback = help

  var rait: Trigger_Command
  rait.reg = re"^ *!rating *$"
  rait.callback = rating

  var badWords: Trigger_Words
  badWords.words = readFile(getAppDir() / "badwords.txt").splitLines()
  badWords.callback = badwordCallback

  bot.triggers.commands.add(helper)
  bot.triggers.commands.add(rait)
  bot.triggers.words.add(badWords)
  
  bot.logEnable(true)

  if bot.connect():
    bot.logLine("Bot connected")
  else:
    bot.logLine("Bot not connected ERRRRRRRRRRRRROR")

  while true:
    bot.step()

main()