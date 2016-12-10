/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/

{ lib, styx, styx-themes, runCommand, writeText
, renderDrafts ? false
, siteUrl ? null
}@args:

let styxLib = import "${styx}/share/styx/lib" {
  inherit lib;
  pkgs = { inherit styx runCommand writeText; };
};
in with styxLib;

let

  /* Configuration loading
  */
  conf = let
    conf       = import ./conf.nix;
    themesConf = styxLib.themes.loadConf themes;
    mergedConf = recursiveUpdate themesConf conf;
  in
    overrideConf mergedConf args;

  /* Load themes templates
  */
  templates = styxLib.themes.loadTemplates {
    inherit themes defaultEnvironment customEnvironments;
  };

  /* Load themes static files
  */
  files = styxLib.themes.loadFiles themes;


/*-----------------------------------------------------------------------------
   Themes setup

-----------------------------------------------------------------------------*/

  /* Themes used
  */
  themes = [ ./themes/styx-site styx-themes.showcase ];


/*-----------------------------------------------------------------------------
   Template environments

-----------------------------------------------------------------------------*/

  /* Default template environment
  */
  defaultEnvironment = { inherit conf templates data pages; lib = styxLib; };

  /* Custom environments for specific templates
  */
  customEnvironments = {
    partials.head = defaultEnvironment // { feed = pages.feed; };
  };

/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
   the data set is included in the default template environment
-----------------------------------------------------------------------------*/

  data = {
    # loading a list of contents
    posts  = let
      postsList = loadDir { inherit substitutions; dir = ./posts; };
      # include drafts only when renderDrafts is true
      draftsList = optionals renderDrafts (loadDir { inherit substitutions; dir = ./drafts; isDraft = true; });
    in sortBy "date" "dsc" (postsList ++ draftsList);
    # Navbar data
    navbar = let
      documentation = { title = "Documentation"; href = "documentation.html"; };
      github = { title = "GitHub ${templates.icon.fa "github"}"; href = "https://github.com/styx-static/styx/"; };
      rss = { title = templates.icon.fa "rss-square"; href = pages.feed.href; };
    in
      [ pages.news documentation github rss ];
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = rec {

    index = {
      title = "Home";
      href  = "index.html";
      template = templates.index;
    };

    news = {
      title = "News";
      href  = "news.html";
      template = templates.news;
      inherit posts;
    };

    feed = {
      href = "feed.xml";
      template = templates.feed;
      items = take 10 pages.posts;
      layout = id;
    };

    posts = mkPageList {
      data = data.posts;
      hrefPrefix = "posts/";
      template = templates.post.full;
    };

  };


/*-----------------------------------------------------------------------------
   generateSite arguments preparation

-----------------------------------------------------------------------------*/

  pagesList = let
    # converting pages attribute set to a list
    list = pagesToList pages;
    # setting a default layout
    in map (setDefaultLayout templates.layout) list;

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


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

in generateSite {
  inherit files pagesList substitutions;

  # generating all versions documentation
  postGen = ''
    ${concatStringsSep "\n" (map (version: ''
      cp ${fetchStyx version}/share/doc/styx/index.html $out/documentation-${version}.html
    '') versions)}
    cp ${fetchStyx (head versions)}/share/doc/styx/index.html $out/documentation.html
  '';
}
