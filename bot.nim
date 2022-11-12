import irc, asyncdispatch, strutils, os, random
randomize()
const
  IrcPort = Port(6667)
  TwitchAddr = "irc.chat.twitch.tv"
  HelpText = """Комманды: t.ly/23de"""
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
        var user = event.params[event.params.low]
        user.delete(0,0)
        let toUser = "@" & user & ", "
        if msg == "!help": 
          client.privmsg(event.origin, HelpText)
        if msg == "!flip":
          if rand(0..1) == 0:
            client.privmsg(event.origin, toUser & "Орёл [true] 1")
          else:  
            client.privmsg(event.origin, toUser & "Решка [false] 0")
      # echo(event.raw)