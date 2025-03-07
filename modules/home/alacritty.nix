{ config
, lib
, ...
}:
let
  palette = config.module.alacritty.palette;
in 
{
  options = {
    module.alacritty = {
      palette = lib.mkOption {
        type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
        default = null;
        description = "Alacritty ricing palette";
      };
    };
  };
  config = {
    programs = {
      alacritty = {
        enable = true;
        settings = {
          env.TERM = "xterm-256color";
          colors = with palette; lib.mkIf (palette != null) {
            bright = {
              black   = "0x${base00}";
              blue    = "0x${base0D}";
              cyan    = "0x${base0C}";
              green   = "0x${base0B}";
              magenta = "0x${base0E}";
              red     = "0x${base08}";
              white   = "0x${base06}";
              yellow  = "0x${base09}";
            };
            cursor = {
              cursor = "0x${base06}";
              text   = "0x${base06}";
            };
            normal = {
              black   = "0x${base00}";
              blue    = "0x${base0D}";
              cyan    = "0x${base0C}";
              green   = "0x${base0B}";
              magenta = "0x${base0E}";
              red     = "0x${base08}";
              white   = "0x${base06}";
              yellow  = "0x${base0A}";
            };
            primary = {
              background = "0x${base00}";
              foreground = "0x${base06}";
            };
          };
          window = {
            dimensions = {lines = 27; columns = 115;};
            padding = {x = 4; y = 4;};
          };
          keyboard.bindings = [
            {action = "Copy"; key = "C";mods = "Control";}
            {action = "Paste";key = "V";mods = "Control";}
            {action = "Paste";key = "М";mods = "Control";}
            {action = "PasteSelection";key = "Insert";mods = "Shift";}
            {chars = "\\u0003";key = "C";mods = "Control|Shift";}
          ];
        };
      };
    };
  };
}
