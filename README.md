# tls-mailer

## Presentation

Lua library to send email via SMTP servers with TLS.

It can actually send email, but is obviously not ready for prime time.

## Dependencies

- [LuaSocket](https://github.com/diegonehab/luasocket)
- [LuaSec](https://github.com/brunoos/luasec)

## Basic usage

```lua
local tls_mailer = require "tls-mailer"

local mailer = tls_mailer.new{
  server = "mail.example.com",
  user = "smtp@example.com",
  password = "V3ryS3cr37",
}

local r, e = mailer:send{
  from = "sender@example.com",
  to = "receiver@example.com",
  subject = "my subject",
  text = "my body text",
  attach = {{ -- facultative
    mimetype = "application/stuff",
    fname = "myfile.xxx",
    source = {string = "Hello!"},
    -- or: source = {fname = "myfile.xxx"},
  }},
}
```

## Copyright

Copyright (c) 2013 Moodstocks SAS
