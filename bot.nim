import irc, asyncdispatch, strutils, os, random, sequtils
randomize()
const
  IrcPort = Port(6667)
  TwitchAddr = "irc.chat.twitch.tv"
  Chanel = "#levshx"
  BotNick = "levshxbot"

var badWords = readFile("badwords.txt").splitLines()

var client = newIrc(
    address = TwitchAddr,
    port = IrcPort,
    nick = BotNick,
    serverPass = readFile("oauth.key"),
    joinChans = @[Chanel]
  )


while not client.isConnected():
  try:
    client.connect()
    client.privmsg(Chanel, "Bot was started")
    client.send("CAP REQ :twitch.tv/commands twitch.tv/tags")
  except:
    sleep(10000)

while true:
  while not client.isConnected():
    try:
      client.connect()
      client.privmsg(Chanel, "Bot was restarted") 
      client.send("CAP REQ :twitch.tv/commands twitch.tv/tags")     
    except:
      sleep(10000)
  
  try:
    var event: IrcEvent
    if client.poll(event):
      case event.typ
      of EvConnected:
        discard
      of EvDisconnected, EvTimeout:
        break
      of EvMsg:
        if event.cmd == MPrivMsg:
          var msg = event.params[event.params.high]
          var user = event.params[event.params.low]
          user.delete(0,0)
          let toUser = "@" & user & ", "
          if msg == "!help": 
            client.privmsg(event.origin, toUser &  "Commands: t.ly/23de")         
          elif msg == "!flip":
            if rand(0..1) == 0:
              client.privmsg(event.origin, toUser & "Орёл [true] 1")
            else:  
              client.privmsg(event.origin, toUser & "Решка [false] 0")
          else:
            msg = multiReplace(msg, @[(".", ""),(",", ""),("!", ""),("?", ""),(":", "")])        
            if any(msg.splitWhitespace(), proc (x: string): bool = any(badWords, proc (y: string): bool = x.toLower() == y)):
              client.privmsg(event.origin, toUser &  "подбирай выражения HUH")  
        if event.cmd == MUnknown:
          #Парсим не стандартные события IRC Twitch
          echo "lel"
        echo(event.raw)
  except:
    sleep(500)