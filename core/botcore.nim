import twitch_irc, re, strutils, std/[times, os], random, sequtils, triggers

export re, triggers, random

randomize()

const
  TwitchAddr = "irc.chat.twitch.tv"

type 
  TwitchBot* = object
    irc_client: Irc
    sharp_chanel: string
    chanel: string
    botNick: string
    oAuthKey: string
    log: bool
    logFile: string
    triggers*: tuple [
      commands: seq[tuple [
        reg: Regex,        
        callback: proc (nick: string, args: seq[string]),
      ]],
      words: seq[tuple [
        words: seq[string],
        callback: proc (nick: string),
      ]],
      twitch_sub: seq[tuple [    
        callback: proc (nick: string),
      ]],
      twitch_resub: seq[tuple [
        level: int,
        month: int,
        callback: proc (nick: string, month: int, level: int),
      ]],
      twitch_follow: seq[tuple [
        callback: proc (nick: string),
      ]],
      newChatter: seq[tuple [
        callback: proc (nick: string),
      ]],      
    ]

proc connect*(self: var TwitchBot): bool =
  self.irc_client.connect()
  if self.irc_client.isConnected():
    self.irc_client.send("CAP REQ :twitch.tv/commands twitch.tv/tags")
  return self.irc_client.isConnected()

proc isConnected*(self: TwitchBot): bool =
  return self.irc_client.isConnected()

proc sendMessage*(self: TwitchBot, text: string): void = 
  self.irc_client.privmsg(self.sharp_chanel, text)

proc newTwitchBot*(botNick: string, oAuthKey: string, chanel: string): TwitchBot =
  result.botNick = botNick
  result.oAuthKey = oAuthKey
  result.chanel = chanel
  result.sharp_chanel = "#" & chanel
  result.log = false
  result.irc_client = newIrc(
    address = TwitchAddr,
    nick = botNick,
    serverPass = oAuthKey,
    joinChans = @[result.sharp_chanel]
  )

proc logEnable*(self: var TwitchBot, state: bool, file: string = getAppDir() / "LOG.txt"): void =
  self.log = state
  self.logFile = file

proc logLine*(self: TwitchBot, text: string): void = 
  if self.log:
    var logFile = open(self.logFile, fmAppend)
    logFile.writeLine("[" & $now()  & "] " & text)
    echo "[" & $now()  & "] " & text
    logFile.close()

proc step*(self: var TwitchBot): void =    
  if self.isConnected():    
      var event: IrcEvent
      if self.irc_client.poll(event):
        case event.typ
        of EvConnected:
          discard
        of EvDisconnected, EvTimeout:
          discard
        of EvMsg:
          let msg = event.params[event.params.high]
          let msg_words = multiReplace(msg, @[(".", ""),(",", ""),("!", ""),("?", ""),(":", ""),("_", "")]) 
          let user = event.nick 
          if event.cmd == MPrivMsg:       
            for command in self.triggers.commands:
              var matches: array[20,string]
              if match(msg, command.reg, matches):
                var args: seq[string] = matches.toSeq
                for argN in countdown(args.len-1, 0):
                  if args[argN]=="":
                    args.delete(argN)                
                command.callback(user, args)
            for wordt in self.triggers.words:                            
              if any(msg_words.splitWhitespace(), proc (x: string): bool = any(wordt.words, proc (y: string): bool = x.toLower() == y)):
                wordt.callback(user)
                       
          # if event.cmd == MJoin:
          #   client.privmsg(Chanel, user & " привет! catJAMPARTY")
          # if event.cmd == MPart:
          #   client.privmsg(Chanel, user & " пока wideVIBE") 
          # if event.cmd == MUnknown:
          #   echo "Unknown"
          if self.log:
            self.logLine(event.raw)  
  os.sleep(10)