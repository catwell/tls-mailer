local smtp, mime, ltn12, ssl, tls_params
local is_openresty = not not _G.ngx

if is_openresty then

  smtp = require "resty.smtp"
  mime = require "resty.smtp.mime"
  ltn12 = require "resty.smtp.ltn12"

  tls_params = function(check_cert)
    return {
      port = 465,
      ssl = {
        enable = true,
        verify_cert = (not not check_cert),
      },
    }
  end

else

  socket = require "socket"
  smtp = require "socket.smtp"
  ltn12 = require "ltn12"
  ssl = require "ssl"

  tls_params = function(check_cert)
    return {
      mode = "client",
      options = "all",
      port = 465,
      protocol = "tlsv1",
      verify = check_cert and "peer" or "none",
    }
  end

end

local map_merge = function(m1, m2)
  for k,v in pairs(m2) do
    if m1[k] == nil then m1[k] = v end
  end
end

local tls_tcp = function(pp)

  local cnx_idx = function(self, key)
    return function(proxy, ...)
      return proxy.sock[key](proxy.sock, ...)
    end
  end

  local cnx_connect = function(pp)
    return function(self, host, port)
      socket.try(self.sock:connect(host, port))
      self.sock = socket.try(ssl.wrap(self.sock, pp))
      socket.try(self.sock:dohandshake())
      return 1
    end
  end

  return function()
    local cnx = {
      sock = socket.try(socket.tcp()),
      connect = cnx_connect(pp),
    }
    return setmetatable(cnx, {__index = cnx_idx})
  end

end

local email_for; email_for = function(x)
  if type(x) == "string" then
    return string.format("<%s>", x)
  elseif type(x) == "table" then
    assert(x.email)
    return email_for(x.email)
  else error("bad type") end
end

local header_for = function(x)
  if type(x) == "string" then
    return email_for(x)
  elseif type(x) == "table" then
    assert(x.email and x.name)
    return string.format("%s <%s>", x.name, x.email)
  else error("bad type") end
end

local send = function(self, pp)
  assert(pp.from and pp.to and pp.subject and pp.text)
  local headers = {
    from = header_for(pp.from),
    to = header_for(pp.to),
    subject = pp.subject,
  }
  local body = {{
    headers = {
      ["content-type"] = "text/plain; charset=UTF-8",
      ["content-transfer-encoding"] = "quoted-printable",
    },
    body = ltn12.source.chain(
      ltn12.source.string(pp.text),
      ltn12.filter.chain(
        mime.normalize(),
        mime.encode("quoted-printable"),
        mime.wrap("quoted-printable")
      )
    ),
  }}
  if pp.attach then
    local att
    for i=1,#pp.attach do
      att = pp.attach[i]
      assert(att.mimetype and att.fname and att.source)
      assert(att.source.string or att.source.fname)
      local _h = {
        ["content-type"] = string.format(
          "%s; name=\"%s\"", att.mimetype, att.fname
        ),
        ["content-disposition"] = string.format(
          "attachment; filename=\"%s\"", att.fname
        ),
        ["content-transfer-encoding"] = "base64",
      }
      local _s
      if att.source.string then
        _s = ltn12.source.string(att.source.string)
      else
        _s = ltn12.source.file(io.open(att.source.fname, "rb"))
      end
      local _b = ltn12.source.chain(
        _s,
        ltn12.filter.chain(
          mime.normalize(),
          mime.encode("base64"),
          mime.wrap("base64")
        )
      )
      body[#body+1] = {
        headers = _h,
        body = _b,
      }
    end
  end
  local source = smtp.message{
    headers = headers,
    body = body,
  }
  local msg = {
    from = email_for(pp.from),
    rcpt = email_for(pp.to),
    source = source,
  }
  if self.use_tls then
    local params = tls_params(self.check_cert)
    map_merge(params, self.params)
    map_merge(msg, params)
    if not is_openresty then
      msg.create = tls_tcp(params)
    end
  else
    map_merge(msg, self.params)
  end
  local r, e = smtp.send(msg)
  if r == 1 then
    return true, {email = msg.rcpt}
  else
    return false, {r = r, e = e}
  end
end

local methods = {
  send = send,
}

local new = function(pp)
  assert(
    (type(pp.server) == "string") and
    (type(pp.user) == "string") and
    (type(pp.password) == "string")
  )
  local r = {
    use_tls = (pp.use_tls == nil) or pp.use_tls,
    check_cert = (pp.check_cert == nil) or pp.check_cert,
    params = {
      server = pp.server,
      user = pp.user,
      password = pp.password,
      port = pp.port,
    },
  }
  return setmetatable(r, {__index = methods})
end

return {
  new = new,
}
