# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Fix vscode server
      (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Low-level hardware config
  powerManagement.powertop.enable = true;

  networking.hostName = "sinix"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable ZSH as the default shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;  

  users.users.simon = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAzNTYXbLXqEA8N3AKJO3WkEP7jRt2NTyV62zquwmztWX1yHxfc/KQODIjv7jM4ckOfFN1DccHk8Euv5kx3xB7Ay4B5+CPSm/c7m4Y2GH4aUEvvaUnUr/L9ocWF7Cek0NNCfLxKL5osprHIjFp9ZxuYhZ98RMI4kn1ybe9ukRwSH/xQvm/u8yWsf4j7clvTI7rwy80EHG8+WjYy4eXHuCvcW8AOONAZW20N7g3f0NS+RHMoC1N83mzuJLMt3kCt5BrSjJzapqi0FnJZtq1thY41hybkDx8NgqdeSvw8vOkEyxZsw8TTtJuTR9OutuiuRtgNJo3d6YkpiNYKPJZ0yey7w=="
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    htop
    iftop
    ncdu
    pciutils
    rclone
    screen
    wget
    btrfs-progs
    mergerfs
    gptfdisk
  ];

  # BTRFS raid1 filesystem
  fileSystems."/mnt/raid" = 
  {
    device = "/dev/disk/by-uuid/94164f56-a397-4bf5-bf5a-9d2a24a4a69c";
    fsType = "btrfs";
  };

  fileSystems."/appdata" = 
  {
    depends = [
      "/mnt/raid" 
    ];
    device = "/dev/disk/by-uuid/94164f56-a397-4bf5-bf5a-9d2a24a4a69c";
    fsType = "btrfs";
    options = [
      "subvol=appdata"
      "compress=zstd"
    ];
  };

  # JBODs - the spinning disks
  fileSystems."/mnt/jbod/jbod1" = 
  {
    device = "/dev/disk/by-label/jbod1";
    fsType = "ext4";
  };

  fileSystems."/storage" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/jbod/*";
    options = [
      "defaults" "nonempty" "allow_other" "use_ino" "cache.files=off" "moveonenospc=true" "dropcacheonclose=true" "minfreespace=200G" "category.create=mfs"
    ];
  };

 # TODO put a swap somewhere else, btrfs doesn't support swap on multidevice filesystems
/*
  fileSystems."/swap" = 
  {
    depends = [
      "/mnt/raid" 
    ];
    device = "/dev/disk/by-uuid/94164f56-a397-4bf5-bf5a-9d2a24a4a69c";
    fsType = "btrfs";
    options = [
      "subvol=swap"
      "noatime"
    ];
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];
  */

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
  
  # Weekly btrfs scrub - checks that all data is good.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };

  services.vscode-server.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false; # TODO

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11"; # Did you read the comment?
}

