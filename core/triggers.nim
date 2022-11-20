import re, times
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
        callback: proc (nick: string, month: int),
    ]
    Trigger_Raid* = tuple [
        callback: proc (nick: string, month: int),
    ]
    Trigger_Unraid* = tuple [
        callback: proc (nick: string, month: int),
    ]
    Trigger_New_Chatter* = tuple [
        callback: proc (nick: string),
    ]
    Trigger_Cron* = tuple [
        timeout: Duration,
        last_time: DateTime,
        callback: proc (),
    ]