# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "klerpi";
    homeDirectory = "/home/klerpi";
  };
  programs.home-manager.enable = true;

  # GNOME Tweaks
  dconf = {
    enable = true;
    settings = {
      # Choose dark mode
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        font-name = "Inter 11";
        document-font-name = "Inter 11";
        monospace-font-name = "Ubuntu Mono 11";
        titlebar-font = "Inter Semi-Bold 11";
      };
      # Set background
      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/fold-l.jpg";
        picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/fold-d.jpg";
        picture-options = "spanned";
        primary-color = "#26a269";
        secondary-color = "#000000";
      };
      "org/gnome/mutter".edge-tilling = true;
      "org/gnome/desktop/session".idle-delay = 600;
      "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
      "org/gnome/desktop/media-handling".autorun-never = true;
      "org/gnome/desktop/wm/preferences".action-middle-click-titlebar = "minimize";
    };
  };

  home.packages = with pkgs; [
    alejandra
    neovim
    prismlauncher
  ];

  programs.git = {
    enable = true;
    userName = "klerpi";
    userEmail = "git@klerpi.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.fhs;
    userSettings = {
      window.zoomLevel = 1.2;
      window.dialogStyle = "custom";
      window.titleBarStyle = "custom";
      editor.fontFamily = "Ubuntu Mono";
      editor.fontSize = 15;
      editor.minimap.enabled = false;
      editor.formatOnSave = true;
      terminal.integrated.fontSize = 15;
      debug.console.fontSize = 15;
      breadcrumbs.enabled = false;
      workbench.iconTheme = "vscode-icons";
      git.autofetch = true;
      git.confirmSync = false;
      # Disable auto updates (rely on NixOS for updates)
      extensions.autoCheckUpdates = false;
      update.mode = "none";
    };
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      kamadorueda.alejandra
      vscode-icons-team.vscode-icons
    ];
  };

  programs.firefox = {
    enable = true;
    profiles.klerpi = {
      isDefault = true;
      search.force = true;
      search.default = "DuckDuckGo";
      search.order = ["DuckDuckGo" "Nix Packages" "NixOS Wiki" "Home Manager Options"];

      search.engines = {
        "Nix Packages" = {
          urls = [
            {
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          definedAliases = ["@pkg"];
        };

        "NixOS Wiki" = {
          urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
          definedAliases = ["@nw"];
        };

        "Home Manager Options" = {
          urls = [{template = "https://home-manager-options.extranix.com/?query={searchTerms}";}];
          definedAliases = ["@hm"];
        };

        "Google".metaData.hidden = true;
        "Bing".metaData.hidden = true;
      };

      settings = {
        # From https://brainfucksec.github.io/firefox-hardening-guide
        "browser.aboutConfig.showWarning" = false;
        "browser.startup.page" = 0;
        # Disable activity stream on new windows and tab pages
        "browser.newtabpage.enabled" = false;
        "browser.newtab.preload" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.default.sites" = "";
        # Geolocation / Language
        "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
        "geo.provider.use_gpsd" = false;
        "geo.provider.use_geoclue" = false;
        "browser.region.network.url" = "";
        "browser.region.update.enabled" = false;
        "intl.accept_languages" = "en-US, en";
        "javascript.use_us_english_locale" = true;
        # Updates / Recommendations
        "app.update.auto" = false;
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "browser.discovery.enabled" = false;
        # Telemetry
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";
        "browser.ping-centre.telemetry" = false;
        "beacon.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "captivedetect.canonicalURL" = "";
        "network.captive-portal-service.enabled" = false;
        "network.connectivity-service.enabled" = false;
        "privacy.fingerprintingProtection" = true;
        # Safe browsing
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.phishing.enabled" = false;
        "browser.safebrowsing.blockedURIs.enabled" = false;
        "browser.safebrowsing.provider.google4.gethashURL" = "";
        "browser.safebrowsing.provider.google4.updateURL" = "";
        "browser.safebrowsing.provider.google.gethashURL" = "";
        "browser.safebrowsing.provider.google.updateURL" = "";
        "browser.safebrowsing.provider.google4.dataSharingURL" = "";
        "browser.safebrowsing.downloads.enabled" = false;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "browser.safebrowsing.downloads.remote.url" = "";
        "browser.safebrowsing.downloads.remote.block_potentially_unwanted" = false;
        "browser.safebrowsing.downloads.remote.block_uncommon" = false;
        "browser.safebrowsing.allowOverride" = false;
        # Network
        "network.prefetch-next" = false;
        "network.dns.disablePrefetch" = true;
        "network.predictor.enabled" = false;
        "network.http.speculative-parallel-limit" = 0;
        "browser.places.speculativeConnect.enabled" = false;
        "network.dns.disableIPv6" = true;
        "network.gio.supported-protocols" = "";
        "network.file.disable_unc_paths" = true;
        "permissions.manager.defaultsUrl" = "";
        "network.IDN_show_punycode" = true;
        # Search bar
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.fixup.alternate.enabled" = false;
        "browser.urlbar.trimURLs" = false;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.formfill.enable" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.available" = "off";
        "extensions.formautofill.creditCards.available" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "extensions.formautofill.heuristics.enabled" = false;
        "browser.urlbar.quicksuggest.scenario" = "history";
        "browser.urlbar.quicksuggest.enabled" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        # Passwords
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "signon.formlessCapture.enabled" = false;
        "network.auth.subresource-http-auth-allow" = 1;
        # Cache / Memory
        "browser.cache.disk.enable" = false;
        "browser.sessionstore.privacy_level" = 2;
        "browser.sessionstore.resume_from_crash" = false;
        "browser.pagethumbnails.capturing_disabled" = true;
        "browser.shell.shortcutFavicons" = false;
        "browser.helperApps.deleteTempFileOnExit" = true;
        # HTTPS / SSL / TLS / OSCP / CERTS
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_send_http_background_request" = false;
        "browser.xul.error_pages.expert_bad_cert" = true;
        "security.tls.enable_0rtt_data" = false;
        "security.OCSP.require" = true;
        "security.pki.sha1_enforcement_level" = 1;
        "security.cert_pinning.enforcement_level" = 2;
        "security.remote_settings.crlite_filters.enabled" = true;
        "security.pki.crlite_mode" = 2;
        # Headers
        "network.http.referer.XOriginPolicy" = 2;
        "network.http.referer.XOriginTrimmingPolicy" = 2;
        # Audio / Video
        "media.peerconnection.enabled" = false;
        "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;
        "media.peerconnection.ice.default_address_only" = true;
        "media.peerconnection.ice.no_host" = true;
        "webgl.disabled" = true;
        "media.autoplay.default" = 5;
        "media.eme.enabled" = false;
        # Downloads
        "browser.download.useDownloadDir" = false;
        "browser.download.manager.addToRecentDocs" = false;
        # Cookies
        "browser.contentblocking.category" = "strict";
        "privacy.partition.serviceWorkers" = true;
        "privacy.partition.always_partition_third_party_non_cookie_storage" = true;
        "privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage" = true;
        # UI
        "dom.disable_open_during_load" = true;
        "dom.popup_allowed_events" = "click dblclick mousedown pointerdown";
        "extensions.pocket.enabled" = false;
        "extensions.Screenshots.disabled" = true;
        "pdfjs.enableScripting" = false;
        "privacy.userContext.enabled" = true;
        "extensions.enabledScopes" = 5;
        "extensions.webextensions.restrictedDomains" = "";
        "extensions.postDownloadThirdPartyPrompt" = false;
        # Clear on shutdown
        # "privacy.sanitize.sanitizeOnShutdown" = true;
        # "privacy.clearOnShutdown.cache" = true;
        # "privacy.clearOnShutdown.cookies" = true;
        # "privacy.clearOnShutdown.downloads" = true;
        # "privacy.clearOnShutdown.formdata" = true;
        # "privacy.clearOnShutdown.history" = true;
        # "privacy.clearOnShutdown.offlineApps" = true;
        # "privacy.clearOnShutdown.sessions" = true;
        # "privacy.clearOnShutdown.sitesettings" = false;
        # "privacy.sanitize.timeSpan" = 0;
      };
    };

    # https://mozilla.github.io/policy-templates/
    policies = {
      DisableFirefoxAccounts = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      Bookmarks = [
        {
          Title = "Is It Christmas?";
          URL = "https://isitchristmas.com/";
          Placement = "toolbar";
          Folder = "Sillies";
        }
      ];
      Extensions = {
        Install = [
          # Bitwarden
          https://addons.mozilla.org/firefox/downloads/file/4246600/bitwarden_password_manager-2024.2.1.xpi
          # UBlock Origin
          https://addons.mozilla.org/firefox/downloads/file/4257361/ublock_origin-1.57.0.xpi
          # Sponsorblock
          https://addons.mozilla.org/firefox/downloads/file/4251917/sponsorblock-5.5.9.xpi
          # Unhook
          https://addons.mozilla.org/firefox/downloads/file/4210197/youtube_recommended_videos-1.6.3.xpi
          # BlockTube
          https://addons.mozilla.org/firefox/downloads/file/4247450/blocktube-0.4.2.xpi
        ];
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
