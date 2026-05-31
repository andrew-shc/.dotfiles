local M = {}

-- Send a desktop notification + sound to the local Kitty terminal via OSC 99.
-- Works transparently over SSH — the escape sequence travels through the tunnel.
-- Requires: kitty.conf → enable_audio_bell yes  (for the BEL sound)
--           kitty.conf → notify_on_cmd_finish ... (optional, kitty-side setting)
function M.notify_kitty(title, body)
  local id = tostring(os.time() % 9999)
  body = body or ""
  -- BEL for audible alert
  io.write("\7")
  -- OSC 99: title chunk (d=0 = more data coming)
  io.write(string.format("\27]99;i=%s:d=0:p=title;%s\7", id, title))
  -- OSC 99: body chunk (d=1 = finalise and display)
  io.write(string.format("\27]99;i=%s:d=1:p=body;%s\7", id, body))
  io.flush()
end

return M
