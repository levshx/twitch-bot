import twitch_irc, re, strutils, std/[times, os], random, sequtils, triggers, strtabs

export re, triggers, random, times

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
      command: seq[tuple [
        reg: Regex,        
        callback: proc (nick: string, args: seq[string]),
      ]],
      word: seq[tuple [
        words: seq[string],
        callback: proc (nick: string),
      ]],
      sub: seq[tuple [    
        callback: proc (nick: string),
      ]],
      resub: seq[tuple [
        callback: proc (nick: string, month: int),
      ]],
      new_chatter: seq[tuple [
        callback: proc (nick: string),
      ]], 
      cron: seq[tuple [
        timeout: Duration,
        last_time: DateTime,
        callback: proc (),
      ]], 
    ]

proc connect*(self: var TwitchBot): bool =
  self.irc_client.connect()
  sleep(500)
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
    #cron
    if self.triggers.cron.len>0:
      for cron_n in 0..self.triggers.cron.len-1: 
        let now = now()
        if now - self.triggers.cron[cron_n].last_time > self.triggers.cron[cron_n].timeout:
          self.triggers.cron[cron_n].last_time = now
          self.triggers.cron[cron_n].callback()
          
    var event: IrcEvent
    if self.irc_client.poll(event):
      case event.typ
      of EvConnected:
        self.logLine("Connected succ")
      of EvDisconnected, EvTimeout:
        self.logLine("Disconnected/Timeout: " & $event.typ)
        while not self.connect():
          self.logLine("try reconnect")
        self.logLine("isConnected: " & $self.isConnected())
      of EvMsg:
        self.logLine(event.raw)
        let msg = event.params[event.params.high]
        let msg_words = multiReplace(msg, @[(".", ""),(",", ""),("!", ""),("?", ""),(":", ""),("_", "")]) 
        let user = event.nick 
        if event.cmd == MPrivMsg:       
          for command in self.triggers.command:
            var matches: array[20,string]
            if match(msg, command.reg, matches):
              var args: seq[string] = matches.toSeq
              for argN in countdown(args.len-1, 0):
                if args[argN]=="":
                  args.delete(argN)                
              command.callback(user, args)
          for wordt in self.triggers.word:                            
            if any(msg_words.splitWhitespace(), proc (x: string): bool = any(wordt.words, proc (y: string): bool = x.toLower() == y)):
              wordt.callback(user)
        if event.cmd == MUserNotice:
          case (event.tags["msg-id"]):
          of "sub":
            for subt in self.triggers.sub:
              subt.callback(user)
          of "resub":
            for subt in self.triggers.resub:
              subt.callback(user, parseInt(event.tags["msg-param-cumulative-months"]))
          of "raid":
            echo "Пока не сделал рейд"
          of "unraid":
            echo "Пока не сделал рейд"
          of "ritual":
            if event.tags["msg-param-ritual-name"] == "new_chatter":
              for newchattert in self.triggers.new_chatter:
                newchattert.callback(user)
          else: 
            echo "Undefined"  
        if event.cmd == MReconnect:
          while not self.connect():
            self.logLine("try reconnect")
  os.sleep(10)