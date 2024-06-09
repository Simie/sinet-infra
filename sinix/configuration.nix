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
  powerManagement.cpuFreqGovernor = "powersave";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

##########
# Network Configuration
##########

  networking.hostName = "sinix"; # Define your hostname.
  networking.hostId = "224424a8"; # Generated with `head -c4 /dev/urandom | od -A none -t x4`
  networking.enableIPv6 = false; # too much faff, firewall logs always used ipv6 which makes it harder to work with

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      80 443 # HTTP(S)
      #40000 # Discovery
      1400 # SONOS -> HASS
      1883 # MQTT
      548 # Netatalk (time machine backup)
    ];
    allowedUDPPorts = [
      #1900 1901 137 136 138 # HASS
    ];
    trustedInterfaces = [ "veth_traefik" ];
    logRefusedConnections = true;
  };

##########
# Users
##########

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
    extraGroups = [ 
      "wheel" "users" 
      "dockerapp" # Allow access to files owned by docker apps (e.g. paperless)
    ];
    packages = with pkgs; [
      tree git
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAzNTYXbLXqEA8N3AKJO3WkEP7jRt2NTyV62zquwmztWX1yHxfc/KQODIjv7jM4ckOfFN1DccHk8Euv5kx3xB7Ay4B5+CPSm/c7m4Y2GH4aUEvvaUnUr/L9ocWF7Cek0NNCfLxKL5osprHIjFp9ZxuYhZ98RMI4kn1ybe9ukRwSH/xQvm/u8yWsf4j7clvTI7rwy80EHG8+WjYy4eXHuCvcW8AOONAZW20N7g3f0NS+RHMoC1N83mzuJLMt3kCt5BrSjJzapqi0FnJZtq1thY41hybkDx8NgqdeSvw8vOkEyxZsw8TTtJuTR9OutuiuRtgNJo3d6YkpiNYKPJZ0yey7w=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTD26x297eNd4KiRL2UahydEdIRHVgya85jRQXq8gGO6UYjWlpVPLh1fHmiZdYoWv/vaLPppWe9c4DPUdKKQBx42q0F4NxgwthGNuDVXwniNKo2laEH4/+Xf4oUiGnrNVMotM64JG8k49PZnHYnYa7VdwAzCNMlHV1cigMauSA4Van8su9/6DG3lJ9mFxzYFXz6pzmPRxo2NI3u/MANBIs+nYy0do18bC+wBTKQbyxMCAC0A3ObNVh3OXJqq90wnqJugpGAQhWtk2mbqyZJnP8Yml6/hm59qlzVQbz7pXVMmGpFfmWwPQfQuL//7xUqw/3UFBU6dFPxCPrF2kT9jS/"
    ];
  };

  users.users.timemachine = {
    isNormalUser = true;
  };
  
  # Set users group to well known ID
  #users.groups.users = {
  #  gid = 100;
  #};

  # Non-privileged user for running docker containers
  # Has access to 'users' files so it can act on network shares like a normal user.
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

##########
# Packages
##########

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ncdu
    pciutils
    rclone
    docker-compose
    e2fsprogs # badblocks
    fatrace # Track filesystem events to detect why disks spin up/down
    gptfdisk
    hdparm
    hd-idle
    htop
    hddtemp
    intel-gpu-tools
    iotop
    mergerfs
    mc
    ncdu
    nmap
    nvme-cli
    parted
    powertop
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

##########
# File Systems
##########

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
  # autosnapshot = on
  fileSystems."/mnt/tank/appdata" = {
    device = "tank/appdata";
    fsType = "zfs";
  };

  # personal data file system
  # atime = off
  # autosnapshot = on
  fileSystems."/mnt/tank/personal" = {
    device = "tank/personal";
    fsType = "zfs";
  };*/
  
  # file system to be merged into mergerfs
  # atime = on
  # autosnapshot = off
  #fileSystems."/mnt/tank/fuse" = {
  #  device = "tank/fuse";
  #  fsType = "zfs";
  #};*/

  # JBODs - the spinning disks

  # Setup disks to spin down after inactivity.
  #powerManagement.powerUpCommands = ''
  #   ${pkgs.hd-idle}/sbin/hd-idle -a sda   -l --set SCT=6000 --set STANDBY=1 /dev/disk/by-label/jbod* 
  #''; #${pkgs.hdparm}/sbin/hdparm -S 1 

  # 6TB Seagate Ironwolf
  fileSystems."/mnt/jbod/parity1" = 
  {
    device = "/dev/disk/by-label/parity1";
    fsType = "ext4";
  };
  
  # 3TB WD RED
  fileSystems."/mnt/jbod/jbod1" = 
  {
    device = "/dev/disk/by-label/jbod1";
    fsType = "ext4";
  };
  
  # 3TB WD RED
  fileSystems."/mnt/jbod/jbod2" = 
  {
    device = "/dev/disk/by-label/jbod2";
    fsType = "ext4";
  };

  # Merge JBODs and tank/fuse into one file system
  # Prefer writing to fuse (nvme) for performance during e.g. downloads.
  fileSystems."/mnt/storage" = {
    depends = [
      "/mnt/tank/fuse"
      "/mnt/jbod/jbod1"
      "/mnt/jbod/jbod2"
    ];
    fsType = "fuse.mergerfs";
    device = "/mnt/tank/fuse:/mnt/jbod/*"; # fuse first, see below
    options = [
      "defaults" "nonempty" "allow_other" "use_ino" "cache.files=off" "moveonenospc=true" "dropcacheonclose=true" "minfreespace=200G" 
      "category.create=ff" # ff = first found, so files are created on nvme storage first if there is space
    ];
  };

  # Secondary filesystem that is just the jbods - script (WIP) will move files from fuse -> jbod_storage if they are not accessed in over ~24hrs
  fileSystems."/mnt/jbod_storage" = {
    depends = [
      "/mnt/jbod/jbod1"
#      "/mnt/jbod/jbod2"
    ];
    fsType = "fuse.mergerfs";
    device = "/mnt/jbod/*";
    options = [
      "defaults" "nonempty" "allow_other" "use_ino" "cache.files=off" "moveonenospc=true" "dropcacheonclose=true" "minfreespace=200G" "category.create=mfs"
    ];
  };

#########
# Backups / Replication
#########

  # Snapraid configuration
  services.snapraid = {
    enable = true;
    
    parityFiles = [
      "/mnt/jbod/parity1/snapraid.parity"
    ];

    dataDisks = {
      d1 = "/mnt/jbod/jbod1";
      d2 = "/mnt/jbod/jbod2";
    };

    contentFiles = [
      "/mnt/jbod/jbod1/snapraid.content"
      "/mnt/jbod/jbod2/snapraid.content"
    ];

    exclude = [
      "*.unrecoverable"
      "/tmp/"
      "/lost+found/"
    ];

    sync.interval = "2:00"; # Daily 2AM
  };
  
  # Sanoid - automatic zfs snapshots
  services.sanoid = {
    enable = true;

    # Personal data likely to be changed/deleted and need recovery a long time after the fact
    templates.personaldata = {
      yearly = 2;
      monthly = 12;
      weekly = 4;
      daily = 7;
      hourly = 24;
      autosnap = true;
      autoprune = true;
    };

    # More rapid turnover data (database and such), less frequent snapshots to avoid bloating disk
    templates.appdata = {
      monthly = 2;
      weekly = 2;
      daily = 7;
      hourly = 10;
      autosnap = true;
      autoprune = true;
    };

    datasets."tank/personal" = {
      useTemplate = ["personaldata"];
    };

    datasets."tank/appdata" = {
      useTemplate = ["appdata"];
    };
  };

#  # Restic - remote backups
#  services.restic = {
#    backups = {
#      appdata = {
#        repository = "";
#      }
#    }
#  };

##########
# System Services
##########

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # Prometheus Node Exporter
  services.prometheus.exporters.node = {
      enable = true;
      port = 9901;
  };

  # Prometheus ZFS exporter
  services.prometheus.exporters.zfs = {
    enable = false; # Doesn't seem to be needed, node exporter has the same info
    port = 9902;
  };

  # Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    openFirewall = true;
  };

  # Dev - enable vscode server
  services.vscode-server.enable = true;

##########
# Samba Shares
##########

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
      force user = dockerapp
      force group = dockerapp
      load printers = no
      unix extensions = no
      hosts allow = 192.168.1. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
    '';
    shares = {
      Public = {
        path = "/data/Public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0666"; # Anyone can read/write, no execute.
        "directory mask" = "0777"; # Anyone can read/write/execute
      };
      Personal = {
        path = "/data/Personal";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0770"; # Only user/group can read/write/execute
        "directory mask" = "0770"; # Only user/group can read/write/execute
        "valid users" = "simon"; # Only allow access to specific users (in this case, me)
        "follow symlinks" = "yes";
        "wide links" = "yes";
      };
    };
  };

##########
# Time machine backup
##########

  services.netatalk = {
    enable = true;
    port = 548; # Default, opened in firewall in networking section
    settings = {
      Global = {
        "mimic model" = "TimeCapsule6,106";  # show the icon for the first gen TC
      };
      time-machine = {
          path = "/mnt/storage/backups/time-machine";
          "valid users" = "timemachine";
          "time machine" = true;
          "vol size limit" = 1024 * 850; # 850GB 
      };
    };
  };

  services.avahi = {
    enable = true;
    openFirewall = true;
    nssmdns4 = true;
    allowInterfaces = ["eno1"];

    publish = {
      enable = true;
      userServices = true;
    };
  };
  
##########
# Docker configuration + systemd wrappers for service stacks
##########

  # Setup docker
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;

  systemd.services.stack-infra = {
    wantedBy = ["multi-user.target"];
    path = [ pkgs.docker-compose ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/simon/sinet-infra/sinix/services/service-compose infra up --wait";
      ExecStop = "/home/simon/sinet-infra/sinix/services/service-compose infra down";
      RemainAfterExit = "yes";
    };

    after = ["docker.service"];
  };

  systemd.services.stack-telemetry = {
    wantedBy = ["multi-user.target"];

    path = [ pkgs.docker-compose ];
    preStart = "/home/simon/sinet-infra/sinix/services/service-compose telemetry down";
    script = "/home/simon/sinet-infra/sinix/services/service-compose telemetry up";
    postStop = "/home/simon/sinet-infra/sinix/services/service-compose telemetry down";

    after = [ "stack-infra.service" ];
  };

  systemd.services.stack-homeassist = {
    wantedBy = ["multi-user.target"];

    path = [ pkgs.docker-compose ];
    preStart = "/home/simon/sinet-infra/sinix/services/service-compose homeassist down";
    script = "/home/simon/sinet-infra/sinix/services/service-compose homeassist up";
    postStop = "/home/simon/sinet-infra/sinix/services/service-compose homeassist down";

    after = [ "stack-infra.service" ];
  };

##########
# Telemetry
##########

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11"; # Did you read the comment?
}

