import irc, asyncdispatch, strutils, os
const
  IrcPort = Port(6667)
  TwitchAddr = "irc.chat.twitch.tv"
  HelpText = """Комманды туть github.com/levshx/twitch-bot"""
var client = newIrc(address = TwitchAddr,
                port = IrcPort,
                nick="levshxbot",
                serverPass = readFile("oauth.key"),
                joinChans = @["#levshx"])

client.connect()
while true:
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
        if msg == "!help": client.privmsg(event.origin, "!help — помощ для нубиков")
        if msg == "!lag":
          client.privmsg(event.origin, formatFloat(client.getLag))
        if msg == "!excessFlood":
          for i in 0..10:
            client.privmsg(event.origin, "TEST" & $i)
      
      echo(event.raw)