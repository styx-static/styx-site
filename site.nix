/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/
{ lib, styx, runCommand, writeText
, styx-themes
, extraConf ? {}
, imagemagick
}@args:

rec {

  /* Library loading
  */
  styxLib = import styx.lib args;


/*-----------------------------------------------------------------------------
   Themes setup

-----------------------------------------------------------------------------*/

  /* list the themes to load, paths or packages can be used
     items at the end of the list have higher priority
  */
  themes = [
    styx-themes.generic-templates
    ./themes/styx-site
  ];

  /* Loading the themes data
  */
  themesData = styxLib.themes.load {
    inherit styxLib themes;
    extraEnv  = { inherit data pages; };
    extraConf = [ ./conf.nix extraConf ];
  };

  /* Bringing the themes data to the scope
  */
  inherit (themesData) conf lib files templates env;


/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
-----------------------------------------------------------------------------*/

  data = with lib; {
    posts  = sortBy "date" "dsc" (loadDir { dir = ./posts; inherit env; });

    doc = lib.fold (v: acc:
      acc // { "${v}" = mkDocPath v; }
    ) {} versions;

    navbar = [
      pages.news
      { title = "Documentation"; path = "/documentation/index.html"; }
      pages.themesList
      { title = "GitHub ${templates.icon.font-awesome "github"}"; url = "https://github.com/styx-static/styx/"; }
      (pages.feed // { navbarTitle = templates.icon.font-awesome "rss-square"; })
    ];

    # themes meta information to generate the themes list
    themes = with lib;
      let
        themesDrv = (filterAttrs (k: v: isDerivation v) styx-themes);
        data      = map (t: styxLib.themes.loadData { inherit styxLib; theme = t; }) (attrValues themesDrv);
        # adding screenshot data
        data'     = map (t:
                      let
                        preMeta = { meta.name = t.meta.id; };
                        postMeta = if t.meta ? screenshot 
                                   then { meta = {
                                      screenshotPath = "/imgs/themes/${t.meta.id}.png";
                                      thumbnailPath  = "/imgs/themes/${t.meta.id}-thumb.png";
                                   }; } else {};
                      in styxLib.utils.merge [ preMeta t postMeta ]
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
    default = { layout = templates.layout; };
  };

  # fetch the versions to create the documentations
  fetchStyx = version:
    import (fetchTarball "https://github.com/styx-static/styx/archive/${version}.tar.gz") {};

  # list of versions to generate documentation from
  versions = [
    "v0.6.0"
    "v0.5.0"
    "v0.4.0"
    "v0.3.1"
    "v0.3.0"
    "v0.2.0"
    "v0.1.0"
  ];

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
          ${imagemagick}/bin/convert "${t.meta.screenshot}" "$out${t.meta.screenshotPath}"
          ${imagemagick}/bin/convert "${t.meta.screenshot}" -resize 720 -gravity north -extent 720x500 "$out${t.meta.thumbnailPath}"
        ''
      ) data.themes}

      # Manuals
      ${lib.concatStringsSep "\n" (map (version: ''
        mkdir -p $out/documentation/${version}/
        cp -r ${fetchStyx version}/share/doc/styx/* $out${mkDocPath version}
      '') versions)}
      cp -r ${fetchStyx (lib.head versions)}/share/doc/styx/* $out/documentation/
    '';
  };

}
