{ inputs
, self
, systemModules
, homeModules
, disko
, ...
}:
{
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    disko.nixosModules.disko
    (import ./disk-config.nix)
    (import ./hardware.nix)
    inputs.home-manager.nixosModules.home-manager
    (
      {inputs, config, pkgs, ...} : {
        imports = systemModules;
        sops = {
          age.keyFile = "/root/.config/sops/age/keys.txt";
          defaultSopsFile = ../../secrets.yaml;
          secrets = {
          "matrix/sharedSecret" = { owner = "matrix-synapse"; };
          #  "mailServerSecret" = { owner="stalwart-mail"; };
          };
        };
        # module.mail-server = {
        #   hostname = "boot.directory";
        #   mailServerSecret = "${config.sops.secrets."mailServerSecret".path}";
        # };
        # users.users.stalwart-mail.extraGroups = [ "acme" ];
        module.matrix.shared_secret = "${config.sops.secrets."matrix/sharedSecret".path}";
        services.nginx = {
          enable = true;
          virtualHosts."${config.networking.domain}" = {
            enableACME = true;
            forceSSL = true;
            root = "${self.packages.x86_64-linux."personal-page"}";
          };
        };
        users.users.nginx.extraGroups = [ "acme" ];
        security.acme = {
          acceptTerms = true;
          certs = {
            "${config.networking.domain}" = {
              email = "letsencrypt@${config.networking.domain}";
              group = "acme";
            };
          };
        };
        networking.hostName = "server";
        networking.domain = "boot.directory";
        networking.firewall.allowedTCPPorts = [ config.services.btcpayserver.port 80 443 ];
        services.openssh = {
          enable = true;
          ports = [22];
          settings.AllowUsers = null;
        };
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        users.users.root = {
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAMRId+WDlD6u83HZx62o0PrCS0aZSnSJT5kXbKI9CaV dmitry@desktop"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKlwdqhLRKjVCv6+DMxw3GiOCE2qK6o9I8Ed9OTTwVQG dmitry@nixos"
          ];
        };
        services.bitcoind = {
          enable = true;
          prune = 10000;
        };
        services.btcpayserver = {
          enable = true;
          address = "0.0.0.0";
        };
        nix-bitcoin = {
          nodeinfo.enable = true;
          generateSecrets = true;
          operator = {
            enable = true;
            name = "dmitry";
          };
        };
        users.users.dmitry = {
          isNormalUser = true;
          description = "dmitry";
          extraGroups = [ "wheel" "docker" ];
        };
        environment.systemPackages = with pkgs; [
          dig
        ];
        i18n.defaultLocale = "en_US.UTF-8";
        time.timeZone = "Europe/Moscow";
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "24.05"; # Did you read the comment?
      }
    )
    (
      {inputs, config, pkgs, ...} : {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs;};
          users.dmitry = {
            imports = homeModules;
            home = {
              homeDirectory = "/home/dmitry";
              stateVersion = "24.05";
              packages = [];
            };
            colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
          };
        };
      }
    )
  ];
}
