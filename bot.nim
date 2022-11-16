import irc, asyncdispatch, strutils, std/[times, os], random, sequtils

randomize()

const
  IrcPort = Port(6667)
  TwitchAddr = "irc.chat.twitch.tv"
  Chanel = "#levshx"
  BotNick = "levshxbot"
  OAuthKey = readFile("oauth.key")

let logFile = open("LOG.txt", fmAppend)

var reload: bool = true

var badWords = readFile("badwords.txt").splitLines()

var client = newIrc(
    address = TwitchAddr,
    port = IrcPort,
    nick = BotNick,
    serverPass = OAuthKey,
    joinChans = @[Chanel]
  )


while not client.isConnected():
  client.connect()
  os.sleep(1000)
  if client.isConnected():
    echo "Connected"
  else:
    echo "Not connected"

client.privmsg(Chanel, "Bot was started")
client.send("CAP REQ :twitch.tv/commands twitch.tv/tags twitch.tv/membership")


while true:
  while not client.isConnected():
    echo "Not connected"
    try:
      client.connect() 
      sleep(1000)          
    except:
      sleep(10000)
    if client.isConnected():
      client.privmsg(Chanel, "Bot was restarted") 
      client.send("CAP REQ :twitch.tv/commands twitch.tv/tags")
  
# try:
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
      if event.cmd == MJoin:  
        var user = event.raw.split("!")[0]
        user.delete(0,0)
        user = "@" & user        
        client.privmsg(event.origin, user & " привет! catJAMPARTY")
        echo ""
        echo event.params
        echo ""
      if event.cmd == MPart: 
        var user = event.raw.split("!")[0]
        user.delete(0,0)
        user = "@" & user    
        client.privmsg(event.origin, user & " пока wideVIBE") 

      
      # if event.cmd == MUnknown:
      #   Парсим не стандартные события IRC Twitch
      #   echo "lel"
      if not defined(GUI): # DEBUG
        echo(event.raw)
      logFile.writeLine("[" & $now()  & "] " & event.raw)
# except:
#   sleep(500)