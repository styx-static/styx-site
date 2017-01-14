/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/
{ lib, styx, runCommand, writeText
, styx-themes
, extraConf ? {}
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
    templates.extraEnv = { inherit data pages; };
    conf.extra = [ (import ./conf.nix) extraConf ];
  };

  /* Bringing the themes data to the scope
  */
  inherit (themesData) conf lib files templates;


/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
-----------------------------------------------------------------------------*/

  data = with lib; {

    posts  = let
      postsList = loadDir { inherit substitutions; dir = ./posts; };
      # include drafts only when renderDrafts is true
      draftsList = optionals (conf ? renderDrafts) (loadDir { inherit substitutions; dir = ./drafts; isDraft = true; });
    in sortBy "date" "dsc" (postsList ++ draftsList);

    navbar = [
      pages.news
      { title = "Documentation"; path = "/documentation.html"; }
      { title = "GitHub ${templates.icon.font-awesome "github"}"; url = "https://github.com/styx-static/styx/"; }
      (pages.feed // { navbarTitle = templates.icon.font-awesome "rss-square"; })
    ];

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
      items    = lib.take 10 pages.posts;
      layout   = lib.id;
    };

    posts = lib.mkPageList {
      data       = data.posts;
      pathPrefix = "/posts/";
      template   = templates.post.full;
    };

  };


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

  pagesList = lib.pagesToList {
    inherit pages;
    default = { layout = templates.layout; };
  };

  # fetch the versions to create the documentations
  fetchStyx = version:
    import (fetchTarball "https://github.com/styx-static/styx/archive/${version}.tar.gz") {};

  versions = [
    "v0.4.0"
    "v0.3.1"
    "v0.3.0"
    "v0.2.0"
    "v0.1.0"
    "master"
  ];

  substitutions = {
    siteUrl = conf.siteUrl;
  };

  site = lib.generateSite {
    inherit files pagesList substitutions;

    # generating all versions documentation
    postGen = ''
      ${lib.concatStringsSep "\n" (map (version: ''
        cp ${fetchStyx version}/share/doc/styx/index.html $out/documentation-${version}.html
      '') versions)}
      cp ${fetchStyx (lib.head versions)}/share/doc/styx/index.html $out/documentation.html
    '';
  };

}
