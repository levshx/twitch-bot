import core/botcore
import strutils

const
  BotNick = "levshxbot"
  OAuthKey = readFile("oauth.key") # create file with bot oauth.key 
  Chanel = "levshx"

var bot = newTwitchBot(BotNick, OAuthKey, Chanel)


if bot.connect():
  echo "bot connected"
else:
  echo "bot not connected ERRRRRRRRRRRRROR"

proc help(nick: string, args: seq[string]) =
  bot.sendMessage(
    "@"&nick&", help :D"
  )

var helper: Trigger_Command
helper.reg = re"^!help"
helper.callback = help

var pay: Trigger_Command
pay.reg = re"^!pay\s+(\w+)\s+(\d+)$"
pay.callback = proc (nick: string, args: seq[string]) = bot.sendMessage(
    "@"&nick&", pay "&args[1]&" moneys, to "&args[0]
  )

let badwords_answers = readFile("badwordsNotice.txt").splitLines()
proc badwordCallback(nick:string) =
  bot.sendMessage("@" & nick & ", " & badwords_answers[rand(0..badwords_answers.len-1)])

var badWords: Trigger_Words
badWords.words = readFile("badwords.txt").splitLines()
badWords.callback = badwordCallback

bot.triggers.commands.add(helper)
bot.triggers.commands.add(pay)
bot.triggers.words.add(badWords)

while true:
  bot.step()