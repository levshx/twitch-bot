import irc, asyncdispatch, strutils, std/[times, os], random, sequtils

randomize()

const
  TwitchAddr = "irc.chat.twitch.tv"

const
  Chanel = "#levshx"
  BotNick = "levshxbot"
  OAuthKey = readFile("oauth.key")

let logFile = open("LOG.txt", fmAppend)

var reload: bool = true

var badWords = readFile("badwords.txt").splitLines()
var badWordsNotice = readFile("badwordsNotice.txt").splitLines()

var client = newIrc(
    address = TwitchAddr,
    nick = BotNick,
    serverPass = OAuthKey,
    joinChans = @[Chanel]
  )



while not client.isConnected():
  client.connect()
  os.sleep(1000)
  if client.isConnected():
    #client.privmsg(Chanel, "Bot was started")
    #client.send("CAP REQ :twitch.tv/commands twitch.tv/tags twitch.tv/membership twitch.tv/ritual ")
    echo "kke"

while true:
  while not client.isConnected():
    echo "Not connected"
    try:
      client.connect() 
      sleep(1000) 
      var event: IrcEvent 
      var kek = client.poll(event)      
    except:
      sleep(10000)
    # if client.isConnected():
    #   client.privmsg(Chanel, "Bot was restarted") 
    #   client.send("CAP REQ :twitch.tv/commands twitch.tv/tags")
    
  try:
    var event: IrcEvent
    if client.poll(event):
      case event.typ
      of EvConnected:
        discard
      of EvDisconnected, EvTimeout:
        break
      of EvMsg:
        var msg = event.params[event.params.high]
        let user = event.nick 
        let toUser = "@" & user & ", "
        if event.cmd == MPrivMsg:       
          let toUser = "@" & user & ", "
          if msg == "!!help": 
            client.privmsg(event.origin, toUser &  "Commands: t.ly/23de")         
          elif msg == "!flip":
            if rand(0..1) == 0:
              client.privmsg(event.origin, toUser & "Орёл [true] 1")
            else:  
              client.privmsg(event.origin, toUser & "Решка [false] 0")
          else:
            msg = multiReplace(msg, @[(".", ""),(",", ""),("!", ""),("?", ""),(":", ""),("_", "")])        
            if any(msg.splitWhitespace(), proc (x: string): bool = any(badWords, proc (y: string): bool = x.toLower() == y)):
              client.privmsg(Chanel, toUser &  badWordsNotice[rand(0..badWordsNotice.len-1)]) 
        # if event.cmd == MJoin:
        #   client.privmsg(Chanel, user & " привет! catJAMPARTY")
        # if event.cmd == MPart:
        #   client.privmsg(Chanel, user & " пока wideVIBE") 
        # if event.cmd == MUnknown:
        #   echo "Unknown"

      
        # if not defined(GUI): # DEBUG
        #   echo(event.raw)    
        logFile.writeLine("[" & $now()  & "] " & event.raw)
  except:
    sleep(500)