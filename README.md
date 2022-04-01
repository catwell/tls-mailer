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

local mailer = tls_mailer.new({
  server = "mail.example.com",
  user = "smtp@example.com",
  password = "V3ryS3cr37",
  cafile = "cacert.pem",
})

local r, e = mailer:send({
  from = "sender@example.com",
  to = "receiver@example.com",
  subject = "my subject",
  text = "my body text",
  attach = { -- facultative array of attachments
    {
      mimetype = "application/stuff",
      fname = "myfile.xxx",
      source = {string = "Hello!"},
      -- or: source = {fname = "myfile.xxx"},
    },
  },
})
```

To deal with certificates, you must pass a CA extract, which you can get for
instance [here](https://curl.se/docs/caextract.html). With OpenResty this is
not necessary and you use [lua_ssl_trusted_certificate] instead.
You can also disable certificate verification (insecure!) with
`check_cert = false`.

[lua_ssl_trusted_certificate]: https://github.com/openresty/lua-nginx-module#lua_ssl_trusted_certificate

## Contributors

- Pierre Chapuis ([@catwell](https://github.com/catwell))
- Christopher Inacio ([@nacho319](https://github.com/nacho319))
- Gran PC ([@GranPC](https://github.com/GranPC))

## Copyright

- Copyright (c) 2013 Moodstocks SAS
- Copyright (c) 2014-2022 Pierre Chapuis
