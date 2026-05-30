{ config, pkgs, lib, hostName, ... }: {
  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
      ];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  # Default networking
  networking = {
    inherit hostName;
    useNetworkd = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users.users."root".openssh.authorizedKeys.keys = [
    # Jue
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRjccH1Tx2UKKSs4Q4GXvq4oV4oT3BGVe5SUHWWa7pVTI8qeii1si3ZlfyZi6r8R3djfz9X/Kvgp/GJL6pH7fSofUU0F4Asb9UmwtY7/34nLXU9HYmdIVVX0to1KubMcJxjoBM2Z+IyNlmkCZpRN+Ztfh+vW+05w5nTTgITfutC18PYkgIIkFJL+SY5UjAY85vy4WmVL7EnQSy3pevBOXLr9ksZQ6N1uC7jSPOgaOQv8IUzFBvdtMZNUu0tXnZiC4w/FShrOTC8XeU0dSWoQQsJXJrdTy6R7gGnR6leQG1uwDsDmEPYOT21JbqurOSqPRQ1coZBjPm5EvhjCRTdqnN jue@air"
    # Nand
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDvc2zp7GYTvm27YptuymOaeDRlHbsfuQyE+9vObP7yWEI3E/GKYh3t9UPnPIF2gEqWEGiUxPjAqvpVZoHqxUL6m2PmKTuhI27//sqop/qp/X1BkzszkaO+m1Rb1qokiOCsSwgOIQCaSZ/jtkzAA6AiF0hw1ZySziz34/4cgNeW0/PdH63qipciZeNP2QIhX7qur2Ye+abueKSt0Uj2lOEpDD4XipnWiyPzfQdo24t5j2l8MyX2g2FQAwJ4nh+W65UoL+LXF2xX7Bukufg6kZCs4q5WsNTpKq4/ILZfW/N4oVEO8XOv0xdZCSnTwyTdcYR9wkcZG7LAWxuM3GIkLx/Z9PhHWyevSVK7+5drlUaeN/N33WAnGhjuoHtd4/3gr/3V+v24/unfJtHz9ZhPeFRmkmzfJvOP6Y8SMLOs0nU80ic5gwIMvA6O1kUHie9xvGEx/ylqj5cHmdgV7aR4oRlWm+XkHU1GH6RZJuyE4x2W4y6K08FxWoGABarCtcMbKGk="
  ];

  # Serve mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.shairport-sync = {
    enable = true;
    openFirewall = true;
  };
  # Hack to bring up socket-activated pipewire
  users.users.${config.services.shairport-sync.user}.uid = 990;
  systemd.services.shairport-sync = {
    requires = [ "user@990.service" ];
    after = [ "user@990.service" ];
    environment = {
      XDG_RUNTIME_DIR = "/run/user/990";
    };
  };

  system.stateVersion = "25.11";
}
