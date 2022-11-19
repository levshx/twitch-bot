import re
type
    Trigger_Command* = tuple [
        reg: Regex,
        callback: proc (nick: string, args: seq[string]),
    ]
    Trigger_Words* = tuple [
        words: seq[string],
        callback: proc (nick: string),
    ]
    Trigger_Sub* = tuple [    
        callback: proc (nick: string),
    ]
    Trigger_Resub* = tuple [
        level: int,
        month: int,
        callback: proc (nick: string, month: int, level: int),
    ]
    Trigger_Follow* = tuple [
        callback: proc (nick: string),
      ]
    Trigger_New_Chatter* = tuple [
        callback: proc (nick: string),
    ]