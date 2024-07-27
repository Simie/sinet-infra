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
    allowPing = true;
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

  # Enable fish as the default shell when bash starts in interactive mode (see https://nixos.wiki/wiki/Fish)
  programs.fish.enable = true;
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  users.groups.ssh  = {}; # Define a group for users allowed login remotely via SSH

  # Setup Users
  users.users.root = {
    extraGroups = [ "ssh" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAzNTYXbLXqEA8N3AKJO3WkEP7jRt2NTyV62zquwmztWX1yHxfc/KQODIjv7jM4ckOfFN1DccHk8Euv5kx3xB7Ay4B5+CPSm/c7m4Y2GH4aUEvvaUnUr/L9ocWF7Cek0NNCfLxKL5osprHIjFp9ZxuYhZ98RMI4kn1ybe9ukRwSH/xQvm/u8yWsf4j7clvTI7rwy80EHG8+WjYy4eXHuCvcW8AOONAZW20N7g3f0NS+RHMoC1N83mzuJLMt3kCt5BrSjJzapqi0FnJZtq1thY41hybkDx8NgqdeSvw8vOkEyxZsw8TTtJuTR9OutuiuRtgNJo3d6YkpiNYKPJZ0yey7w=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTD26x297eNd4KiRL2UahydEdIRHVgya85jRQXq8gGO6UYjWlpVPLh1fHmiZdYoWv/vaLPppWe9c4DPUdKKQBx42q0F4NxgwthGNuDVXwniNKo2laEH4/+Xf4oUiGnrNVMotM64JG8k49PZnHYnYa7VdwAzCNMlHV1cigMauSA4Van8su9/6DG3lJ9mFxzYFXz6pzmPRxo2NI3u/MANBIs+nYy0do18bC+wBTKQbyxMCAC0A3ObNVh3OXJqq90wnqJugpGAQhWtk2mbqyZJnP8Yml6/hm59qlzVQbz7pXVMmGpFfmWwPQfQuL//7xUqw/3UFBU6dFPxCPrF2kT9jS/"
    ];
  };

  users.users.simon = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel" "users" "ssh"
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
    device = "/mnt/tank/fuse:/mnt/jbod/jbod*"; # fuse first, see below
    options = [
      "defaults" "nonempty" "allow_other" "use_ino" "cache.files=off" "moveonenospc=true" "dropcacheonclose=true" "minfreespace=200G" 
      "category.create=ff" # ff = first found, so files are created on nvme storage first if there is space
    ];
  };

  # Secondary filesystem that is just the jbods - script moves files from fuse -> jbod_storage if they are not accessed in over ~24hrs
  fileSystems."/mnt/jbod_storage" = {
    depends = [
      "/mnt/jbod/jbod1"
      "/mnt/jbod/jbod2"
    ];
    fsType = "fuse.mergerfs";
    device = "/mnt/jbod/jbod*";
    options = [
      "defaults" "nonempty" "allow_other" "use_ino" "cache.files=off" "moveonenospc=true" "dropcacheonclose=true" "category.create=mfs"
    ];
  };

#########
# Backups / Replication
#########

  # SSD cache mover
  systemd.services.utility-mover-script = {
    path = [ pkgs.rsync ];
    startAt = "03:00:00";
    after = [ "snapraid-sync.service" "snapraid-scrub.service" "restic-backups-remote-terra.service" ]; # Don't move files to the array while snapraid is busy
    restartIfChanged = false; # Don't automatically start when doing nixos-rebuild.
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/etc/nixos/sinet-infra/sinix/scripts/mover.sh";
    };

    requires = [ "mnt-tank-fuse.mount" "mnt-jbod_storage.mount" ]; # TODO swap to 'RequiresMountsFor'
  };

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
  
  # Sanoid - automatic zfs snapshots (local only)
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

  # Restic - remote backups
  services.restic = {
    backups = {
      remote-terra = {
        extraOptions = [
          "sftp.command='ssh remotebackup@terra.sinet.uk -i /etc/nixos/secrets/remotebackup-private-key -s sftp'"
        ];
        passwordFile = "/etc/nixos/secrets/restic-password";
        paths = [
          "/mnt/tank/appdata"
          "/mnt/tank/personal"
          "/mnt/storage/files"
        ];
        repository = "sftp:remotebackup@terra.sinet.uk:/data/Backup/sinixbackups";
        timerConfig = {
          OnCalendar = "04:30";
          RandomizedDelaySec = "5m";
        };

        initialize = true;

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 1"
        ];
      };
    };
  };

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
      AllowGroups = ["ssh"];
    };
  };

  # Prometheus Node Exporter
  services.prometheus.exporters.node = {
      enable = true;
      port = 9901;
      enabledCollectors = [ "systemd" ];
      extraFlags = [
        "--collector.netdev.device-exclude=^(veth|br-)" # Trim out docker garbage networks
      ];
  };

  # Prometheus ZFS exporter
  services.prometheus.exporters.zfs = {
    enable = false; # Doesn't seem to be needed, node exporter has the same info
    port = 9902;
  };

  # Prometheus systemd exporter
  # Used by alert manager etc so I can tell when backup jobs fail
  services.prometheus.exporters.systemd = {
    enable = true;
    port = 9903;
  };

  # Prometheus restic exporter
  services.prometheus.exporters.restic = {
    enable = false;
    port = 9904;
    # Restic exporter doesn't support sftp.command so can't enable this yet
    # https://github.com/ngosang/restic-exporter/issues/31
    #extraOptions = [
    #  "sftp.command='ssh remotebackup@terra.sinet.uk -i /etc/nixos/secrets/remotebackup-private-key -s sftp'"
    #];
    passwordFile = "/etc/nixos/secrets/restic-password";
    repository = "sftp:remotebackup@terra.sinet.uk:/data/Backup/sinixbackups";
    refreshInterval = 60*60; # Hourly
  };

  # Prometheus smartctl exporter
  # Used by alert manager etc so I can tell when backup jobs fail
  services.prometheus.exporters.smartctl = {
    enable = true;
    port = 9905;
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

   # make shares visible for windows clients
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = sinix
      netbios name = sinix
      guest ok = no
      guest account = nobody
      map to guest = bad user
      load printers = no
      unix extensions = no
      hosts allow = 192.168.1. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
    '';
    shares = {
      Public = {
        "path" = "/mnt/storage/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0666"; # Anyone can read/write, no execute.
        "directory mask" = "0777"; # Anyone can read/write/execute
      };

      Documents = {
        "path" = "/mnt/tank/personal";
        "browseable" = "yes";
        "read only" = "no";
        "create mask" = "0770"; # Only user/group can read/write/execute
        "directory mask" = "0770"; # Only user/group can read/write/execute

        # Paperless manages these files so force all read/writes to go through the user paperless uses
        "force user" = "dockerapp";
        "force group" = "dockerapp";

        "valid users" = "simon"; # Only allow access to specific users (in this case, me)
      };

      Files = {
        "path" = "/mnt/storage/files";
        "browseable" = "yes";
        "read only" = "no";
        "valid users" = "simon"; # Only allow access to specific users (in this case, me)
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
          "vol size limit" = 768000; # 750GB
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
      ExecStart = "/etc/nixos/sinet-infra/sinix/services/service-compose infra up --wait";
      ExecStop = "/etc/nixos/sinet-infra/sinix/services/service-compose infra down";
      RemainAfterExit = "yes";
    };

    after = ["docker.service"];
  };

  systemd.services.stack-telemetry = {
    wantedBy = ["multi-user.target"];

    path = [ pkgs.docker-compose ];
    preStart = "/etc/nixos/sinet-infra/sinix/services/service-compose telemetry down";
    script = "/etc/nixos/sinet-infra/sinix/services/service-compose telemetry up";
    postStop = "/etc/nixos//sinet-infra/sinix/services/service-compose telemetry down";

    after = [ "stack-infra.service" ];
  };

  systemd.services.stack-homeassist = {
    wantedBy = ["multi-user.target"];

    path = [ pkgs.docker-compose ];
    preStart = "/etc/nixos/sinet-infra/sinix/services/service-compose homeassist down";
    script = "/etc/nixos/sinet-infra/sinix/services/service-compose homeassist up";
    postStop = "/etc/nixos/sinet-infra/sinix/services/service-compose homeassist down";

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

