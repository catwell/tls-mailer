# tls-mailer

## Presentation

Lua library to send email via SMTP servers with TLS.

It is designed to work within OpenResty as well as outside of it.

## Dependencies


Note: the rockspec will install the set of dependencies for use
*without* OpenResty.

### With OpenResty

- [resty-smtp](https://github.com/duhoobo/lua-resty-smtp)

### Without OpenResty

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

- Copyright (c) 2013 Moodstocks SAS
- Copyright (c) 2014-2016 Pierre Chapuis
