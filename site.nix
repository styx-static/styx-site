/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/
{ pkgs
, extraConf ? {}
}@args:

rec {

/*-----------------------------------------------------------------------------
   Setup

   This section setup required variables
-----------------------------------------------------------------------------*/

  styx = import pkgs.styx {
    # Used packages
    inherit pkgs;

    # Used configuration
    config = [
      ./conf.nix
      extraConf
    ];

    # Loaded themes
    themes = [
      pkgs.styx.themes.generic-templates
      ./themes/styx-site
    ];

    # Environment propagated to templates
    env = { inherit data pages; };
  };

  # Propagating initialized data
  inherit (styx.themes) conf files templates env lib;

/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
-----------------------------------------------------------------------------*/

  data = with lib; {
    posts  = sortBy "date" "dsc" (loadDir { dir = ./posts; inherit env; });

    doc = lib.mapAttrs (v: _: mkDocPath v) versions;

    navbar = [
      pages.news
      { title = "Documentation"; path = "/documentation/index.html"; }
      pages.themesList
      { title = "GitHub ${templates.icon.font-awesome "github"}"; url = "https://github.com/styx-static/styx/"; }
      (pages.feed // { navbarTitle = (templates.icon.font-awesome "rss-square") + ''<span class="sr-only">RSS</span>''; })
    ];

    # themes meta information to generate the themes list
    themes = with lib;
      let
        data      = map (t: lib.themes.loadData { inherit lib; theme = t; }) (attrValues (removeAttrs pkgs.styx.themes ["outPath"]));
        # adding screenshot data
        data'     = map (t:
                      let
                        preMeta = { meta.name = t.meta.id; };
                        postMeta = optionalAttrs (t.meta ? screenshot) { 
                                     meta = {
                                       screenshotPath = "/imgs/themes/${t.meta.id}.png";
                                       thumbnailPath  = "/imgs/themes/${t.meta.id}-thumb.png";
                                     };
                                   };
                      in lib.utils.merge [ preMeta t postMeta ]
                    ) data;
      in data';
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = rec {

    index = {
      title    = "Home";
      path     = "/index.html";
      template = templates.index;
    };

    news = {
      title    = "News";
      path     = "/news.html";
      template = templates.news;
    };

    feed = {
      path     = "/feed.xml";
      template = templates.feed.atom;
      items    = lib.take 10 pages.posts.list;
      layout   = lib.id;
    };

    posts = lib.mkPageList {
      data       = data.posts;
      pathPrefix = "/posts/";
      template   = templates.post.full;
      breadcrumbs = [ index news ];
    };

    themesList = {
      title    = "Themes";
      path     = "/themes.html";
      template = templates.theme-list;
    };

    themes = lib.map (t:
      t // {
        path        = "/themes/${t.id}.html";
        template    = templates.theme.full;
        title       = t.meta.name;
        breadcrumbs = [ index themesList ];
      }
    ) data.themes;

  };


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

  name = "Styx Official Site";
  
  pageList = lib.pagesToList {
    inherit pages;
    default.layout = templates.layout;
  };

  # fetch the versions to create the documentations
  fetchStyx = version: fetchTarball "https://github.com/styx-static/styx/archive/${version}.tar.gz";
  fetchDivnixStyx = version: fetchTarball "https://github.com/divnix/styx/archive/${version}.tar.gz";
  fetchNixpkgs = rev: fetchTarball "https://github.com/nixos/nixpkgs/archive/${rev}.tar.gz";

  # list of versions to generate documentation from
  versions = {
    "v1.0.0-dev" = (import (fetchDivnixStyx "476e4276960c9445246fa0ce90054dd26950dbe4")).default;
    "v0.7.0" = import (fetchStyx "v0.7.0") { pkgs = import (fetchNixpkgs "2c1838ab99b086dccad930e8dcc504b867149a0c") {};};
    "v0.6.0" = import (fetchStyx "v0.6.0") { pkgs = import (fetchNixpkgs "2c1838ab99b086dccad930e8dcc504b867149a0c") {};};
    "v0.5.0" = import (fetchStyx "v0.5.0") { pkgs = import (fetchNixpkgs "2c1838ab99b086dccad930e8dcc504b867149a0c") {};};
    "v0.4.0" = import (fetchStyx "v0.4.0") { pkgs = import (fetchNixpkgs "2c1838ab99b086dccad930e8dcc504b867149a0c") {};};
    "v0.3.1" = import (fetchStyx "v0.3.1") { pkgs = import (fetchNixpkgs "2c1838ab99b086dccad930e8dcc504b867149a0c") {};};
    "v0.3.0" = import (fetchStyx "v0.3.0") { pkgs = import (fetchNixpkgs "2c1838ab99b086dccad930e8dcc504b867149a0c") {};};
    "v0.2.0" = import (fetchStyx "v0.2.0") { pkgs = import (fetchNixpkgs "2c1838ab99b086dccad930e8dcc504b867149a0c") {};};
    "v0.1.0" = import (fetchStyx "v0.1.0") { pkgs = import (fetchNixpkgs "2c1838ab99b086dccad930e8dcc504b867149a0c") {};};
  };

  substitutions = {
    siteUrl = conf.siteUrl;
  };

  mkDocPath = v: "/documentation/${v}/";

  site = lib.mkSite {
    inherit files pageList substitutions;

    postGen = with lib; ''
      # Themes screenshots
      ${mapTemplate (t:
        optionalString (t.meta ? screenshotPath) ''
          mkdir -p $(dirname "$out${t.meta.screenshotPath}")
          ${pkgs.imagemagick}/bin/convert "${t.meta.screenshot}" "$out${t.meta.screenshotPath}"
          ${pkgs.imagemagick}/bin/convert "${t.meta.screenshot}" -resize 720 -gravity north -extent 720x500 "$out${t.meta.thumbnailPath}"
        ''
      ) data.themes}

      # Manuals
      ${lib.concatStringsSep "\n" (mapAttrsToList (version: package: ''
        mkdir -p $out/documentation/${version}/
        cp -r ${package}/share/doc/styx/* $out/documentation/${version}/
      '') versions)}
      cp -r ${versions.${head (attrNames versions)}}/share/doc/styx/* $out/documentation/
    '';
  };

}
