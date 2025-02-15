{ inputs
, systemModules
, homeModules
, ...
}:
{
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    (import ./hardware.nix)
    inputs.home-manager.nixosModules.home-manager
    (
      {inputs, config, pkgs, lib, ...} : {
        imports = systemModules;
        sops = {
          age.keyFile = "/root/.config/sops/age/keys.txt";
          defaultSopsFile = ../../secrets.yaml;
          secrets = {
            "network/wireguardConfigFile2" = {};
          };
        };
        module.gui.initialUser = "dmitry";
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
          dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
          localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
        };
        networking = {
          hostName = "nixos";
          networkmanager.enable = true;
          networkmanager.dns = "none";
          useDHCP = false;
          dhcpcd.enable = false;
          dhcpcd.extraConfig = "nohook resolv.conf";
          nameservers = [ "8.8.8.8" "8.8.4.4"];
          wg-quick.interfaces.wg0.configFile = "${config.sops.secrets."network/wireguardConfigFile2".path}";
        };
        users.users.root = {
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAMRId+WDlD6u83HZx62o0PrCS0aZSnSJT5kXbKI9CaV dmitry@desktop"
          ];
        };
        services.resolved.enable = false;
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        users.users.dmitry = {
          isNormalUser = true;
          description = "dmitry";
          extraGroups = [ "networkmanager" "wheel" "docker" ];
        };
        environment.systemPackages = with pkgs; [
          dig
          chromium
          k9s
          kubernetes-helm
          kubectl
          yandex-cloud
          awscli2
          minikube
          postgresql
          element-desktop
        ];
        virtualisation.docker.enable = true;
        nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
          "vscode"
          "yandex-cloud"
          "telegram-desktop"
          "discord"
          "steam"
          "steam-original"
          "steam-run"
          "steam-unwrapped"
        ];
        i18n.defaultLocale = "en_US.UTF-8";
        time.timeZone = "Europe/Moscow";
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "24.05"; # Did you read the comment?
      }
    )
    (
      {inputs, config, pkgs, lib, ...} : 
      let
        theme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
        nixColors = inputs.nix-colors.lib-contrib {inherit pkgs;};
      in
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs;};
          users.dmitry = {
            imports = homeModules;
            module = {
              hyprland = {
                palette = theme.palette;
                wallpaper = nixColors.nixWallpaperFromScheme {
                  scheme = theme;
                  width = 2560;
                  height = 1440;
                  logoScale = 15.0;
                };
                gtkTheme = {
                  name = theme.slug;
                  package = nixColors.gtkThemeFromScheme {scheme = theme;};
                };
              };
              waybar.palette = theme.palette;
              alacritty.palette = theme.palette;
              nvim.theme = {
                plugin = nixColors.vimThemeFromScheme {scheme = theme;};
                config = "colorscheme nix-${theme.slug}";
              };
            };
            programs = {
              home-manager.enable = true;
              vscode.enable = true;
            };
            home = {
              homeDirectory = "/home/dmitry";
              stateVersion = "24.05";
              packages = with pkgs; [
                telegram-desktop
                discord
                # system info
                btop
                fastfetch
                # fun
                cmatrix
                cbonsai
                cava
                # files processing
                gnutar
                ffmpeg-full
                # network
                wget
              ];
            };
            colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
          };
        };
      }
    )
  ];
}