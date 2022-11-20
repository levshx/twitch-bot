# Package
version     = "0.0.1"
author      = "levshx"
description = "Twitch bot"
license     = "MIT"
bin = @["bot"]
namedBin["bot"] = "bin/bot"

requires "nim >= 1.6.0"
requires "https://github.com/levshx/twitch-irc"

# exec "nimble build"

task docs, "Generate docs!":
  exec "nim rst2html --index:on --git.url:https://github.com/levshx/nim-steam --git.commit:devel --outdir:docs/html docs/*.rst"
