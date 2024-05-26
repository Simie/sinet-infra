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
      
      #(fetchTarball "https://github.com/nix-community/impermanence/tarball/master")
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Low-level hardware config
  powerManagement.powertop.enable = true;

  networking.hostName = "sinix"; # Define your hostname.
  networking.hostId = "224424a8"; # Generated with `head -c4 /dev/urandom | od -A none -t x4`
  networking.enableIPv6 = false; # too much faff, firewall logs always used ipv6 which makes it harder to work with

  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver

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

  # Setup Users
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAzNTYXbLXqEA8N3AKJO3WkEP7jRt2NTyV62zquwmztWX1yHxfc/KQODIjv7jM4ckOfFN1DccHk8Euv5kx3xB7Ay4B5+CPSm/c7m4Y2GH4aUEvvaUnUr/L9ocWF7Cek0NNCfLxKL5osprHIjFp9ZxuYhZ98RMI4kn1ybe9ukRwSH/xQvm/u8yWsf4j7clvTI7rwy80EHG8+WjYy4eXHuCvcW8AOONAZW20N7g3f0NS+RHMoC1N83mzuJLMt3kCt5BrSjJzapqi0FnJZtq1thY41hybkDx8NgqdeSvw8vOkEyxZsw8TTtJuTR9OutuiuRtgNJo3d6YkpiNYKPJZ0yey7w=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTD26x297eNd4KiRL2UahydEdIRHVgya85jRQXq8gGO6UYjWlpVPLh1fHmiZdYoWv/vaLPppWe9c4DPUdKKQBx42q0F4NxgwthGNuDVXwniNKo2laEH4/+Xf4oUiGnrNVMotM64JG8k49PZnHYnYa7VdwAzCNMlHV1cigMauSA4Van8su9/6DG3lJ9mFxzYFXz6pzmPRxo2NI3u/MANBIs+nYy0do18bC+wBTKQbyxMCAC0A3ObNVh3OXJqq90wnqJugpGAQhWtk2mbqyZJnP8Yml6/hm59qlzVQbz7pXVMmGpFfmWwPQfQuL//7xUqw/3UFBU6dFPxCPrF2kT9jS/"
    ];
  };

  users.users.simon = {
    isNormalUser = true;
    extraGroups = [ "wheel" "users" ];
    packages = with pkgs; [
      tree git
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAzNTYXbLXqEA8N3AKJO3WkEP7jRt2NTyV62zquwmztWX1yHxfc/KQODIjv7jM4ckOfFN1DccHk8Euv5kx3xB7Ay4B5+CPSm/c7m4Y2GH4aUEvvaUnUr/L9ocWF7Cek0NNCfLxKL5osprHIjFp9ZxuYhZ98RMI4kn1ybe9ukRwSH/xQvm/u8yWsf4j7clvTI7rwy80EHG8+WjYy4eXHuCvcW8AOONAZW20N7g3f0NS+RHMoC1N83mzuJLMt3kCt5BrSjJzapqi0FnJZtq1thY41hybkDx8NgqdeSvw8vOkEyxZsw8TTtJuTR9OutuiuRtgNJo3d6YkpiNYKPJZ0yey7w=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTD26x297eNd4KiRL2UahydEdIRHVgya85jRQXq8gGO6UYjWlpVPLh1fHmiZdYoWv/vaLPppWe9c4DPUdKKQBx42q0F4NxgwthGNuDVXwniNKo2laEH4/+Xf4oUiGnrNVMotM64JG8k49PZnHYnYa7VdwAzCNMlHV1cigMauSA4Van8su9/6DG3lJ9mFxzYFXz6pzmPRxo2NI3u/MANBIs+nYy0do18bC+wBTKQbyxMCAC0A3ObNVh3OXJqq90wnqJugpGAQhWtk2mbqyZJnP8Yml6/hm59qlzVQbz7pXVMmGpFfmWwPQfQuL//7xUqw/3UFBU6dFPxCPrF2kT9jS/"
    ];
  };

  # Non-privileged user for running docker containers
  users.users.dockerapp = {
    uid = 1200;
    isSystemUser = true;
    group = "dockerapp";
    extraGroups = [ "users" ];
  };

  users.groups.dockerapp = {
    gid = 1200;
  };

  # Users for Mosquitto (hass stack)
  users.users.mosquitto = {
    uid = 1883;
    isSystemUser = true;
    extraGroups = [ "mosquitto" ];
    group = "mosquitto";
  };

  users.groups.mosquitto = {
    gid = 1883;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ncdu
    pciutils
    rclone
    docker-compose
    e2fsprogs # badblocks
    gptfdisk
    htop
    hddtemp
    intel-gpu-tools
    iotop
    lm_sensors
    mergerfs
    mc
    ncdu
    nmap
    nvme-cli
    parted
    sanoid
    screen
    snapraid
    smartmontools
    tdns-cli
    tmux
    tree
    vim
    wget
  ];

  # 
  # File Systems
  #

  # Boot + Root + Swap File Systems
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c36952a3-c415-4ca0-89c6-aa290630c23f";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A9A2-6DD1";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  boot.kernel.sysctl = { "vm.swappiness" = 10;}; # Prefer not to use swap - it's here for safety but it's on usb flash so don't want it used unless necessary.
  swapDevices = [ {
    device = "/dev/disk/by-partlabel/swap";
    }];

  # Data Storage File Systems
  
  # enable ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  
  boot.zfs.extraPools = [ "tank" ];

  # File systems are automatically mounted by zfs pool - here for reference.
  # compression = ld4
  /*fileSystems."/mnt/tank" = {
    device = "tank";
    fsType = "zfs";
  };

  # appdata file system for docker data etc
  # atime = off
  fileSystems."/mnt/tank/appdata" = {
    device = "tank/appdata";
    fsType = "zfs";
  };*/
  
  # file system to be merged into mergerfs
  # atime = on
  #fileSystems."/mnt/tank/fuse" = {
  #  device = "tank/fuse";
  #  fsType = "zfs";
  #};*/
  
  services.zfs.autoScrub.enable = true;

  # JBODs - the spinning disks

  # Setup disks to spin down after inactivity.
  #powerManagement.powerUpCommands = ''
  #   ${pkgs.hdparm}/sbin/sdparm -l --set SCT=6000 --set STANDBY=1 /dev/disk/by-label/jbod*
  #''; #${pkgs.hdparm}/sbin/hdparm -S 1 

  fileSystems."/mnt/jbod/jbod1" = 
  {
    device = "/dev/disk/by-label/jbod1";
    fsType = "ext4";
  };

  # Merge JBODs and tank/fuse into one file system
  # Prefer writing to fuse (nvme)
  fileSystems."/storage" = {
    depends = [
      "/mnt/tank/fuse"
      "/mnt/jbod/jbod1"
    ];
    fsType = "fuse.mergerfs";
    device = "/mnt/tank/fuse:/mnt/jbod/*"; # fuse first, see below
    options = [
      "defaults" "nonempty" "allow_other" "use_ino" "cache.files=off" "moveonenospc=true" "dropcacheonclose=true" "minfreespace=200G" 
      "category.create=ff" # ff = first found, so files are created on nvme storage first if there is space
    ];
  };

  # Secondary filesystem that is just the jbods - script (WIP) move files from fuse -> jbod_storage if they are not accessed in over ~24hrs
  fileSystems."/jbod_storage" = {
    depends = [
      "/mnt/jbod/jbod1"
    ];
    fsType = "fuse.mergerfs";
    device = "/mnt/jbod/*";
    options = [
      "defaults" "nonempty" "allow_other" "use_ino" "cache.files=off" "moveonenospc=true" "dropcacheonclose=true" "minfreespace=200G" "category.create=mfs"
    ];
  };

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
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = sinix
      netbios name = sinix
      security = user
      guest ok = yes
      guest account = nobody
      map to guest = bad user
      load printers = no
      hosts allow = 192.168.1. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
    '';
    shares = {
      Public = {
        path = "/storage/Public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0666"; # Anyone can read/write, no execute
        "directory mask" = "0777"; # Anyone can read/write/execute
      };
      Personal = {
        path = "/storage/Personal";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0770"; # Only user/group can read/write/execute
        "directory mask" = "0770"; # Only user/group can read/write/execute
        "valid users" = "simon";
      };
      appdata = {
        path = "/mnt/tank/appdata";
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644"; # TODO
        "directory mask" = "0755";
        "admin users" = "simon";
      };
    };
  };
  
  # Setup docker
  virtualisation.docker.enable = true;
  # TODO: docker-compose up on boot?

  # Dev - enable vscode server
  services.vscode-server.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      80 443 # HTTP(S)
      #40000 # Discovery
      1400 # SONOS -> HASS
      1883 # MQTT
    ];
    allowedUDPPorts = [
      #1900 1901 137 136 138 # HASS
    ];
    trustedInterfaces = [ "veth_traefik" ];
    logRefusedConnections = true;
  };

  # Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    openFirewall = true;
  };

  # Prometheus NOde Exporter
  services.prometheus.exporters.node = {
      enable = true;
      port = 9901;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11"; # Did you read the comment?
}

