package = "tls-mailer"
version = "scm-1"

source = {
   url = "git://github.com/catwell/tls-mailer.git",
}

description = {
   summary = "Lua library to send email via SMTP servers with TLS",
   detailed = [[
      Lua library to send email via SMTP servers with TLS.
      Designed to work within OpenResty as well as outside of it.
   ]],
   homepage = "https://github.com/catwell/tls-mailer",
   license = "MIT/X11",
}

dependencies = {
   "lua >= 5.1",
   "luasocket",
   "luasec",
}

build = {
   type = "none",
   install = {
      lua = {
         ["tls-mailer"] = "tls-mailer.lua",
      },
   },
   copy_directories = {},
}
