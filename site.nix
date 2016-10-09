{ pkgs ? import <nixpkgs> {}
, renderDrafts ? false
, siteUrl ? null
, lastChange ? null
}@args:

let lib = import ./lib pkgs;
in with lib;

let

/* Basic setup

   This section is boilerplate code that should not need to be edited
*/

  conf = overrideConf (import ./conf.nix) args;

  themes = [ "styx-site" "default" ];

  state = { inherit lastChange; };

  templates = lib.themes.loadTemplates {
    inherit themes defaultEnvironment customEnvironments;
    themesDir = conf.themesDir;
  };

  files = lib.themes.loadFiles {
    inherit themes;
    themesDir = conf.themesDir;
  };


/* Templates

   This section declare template environments
   The code below is sample and should be customized to fit needs
*/

  # Helper to create font awesome icons
  faIcon = code:
    ''
      <i class="fa fa-${code}" aria-hidden="true"></i>
    '';

  # NavBar setup
  navbar = let
    documentation = { title = "Documentation"; href = "documentation.html"; };
    github = { title = "GitHub ${faIcon "github"}"; href = "https://github.com/styx-static/styx/"; };
    rss = { title = faIcon "rss-square"; href = pages.feed.href; };
  in
    [ pages.news documentation github rss ];

  defaultEnvironment = { inherit conf state lib templates; };

  # Custom environments for templates
  customEnvironments = {
    # Adding navbar and feed variables to the layout template environment
    layout = defaultEnvironment // { inherit navbar; feed = pages.feed; };
  };


/* Pages

   This section declare the site pages
   Every page in this set will be rendered
   The code below is sample and should be customized to fit needs
*/

  # Page declarations
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

    feed = { href = "feed.xml"; template = templates.feed; posts = take 10 posts; layout = id; };

    posts = let
      substitutions = { inherit conf; };
      posts = getPosts { inherit substitutions; from = conf.postsDir; to = "posts"; };
      drafts = optionals renderDrafts (getDrafts { inherit substitutions; from = conf.draftsDir; to = "drafts"; });
      preparePosts = p: p // { template = templates.post.full; };
    in sortPosts (map preparePosts (posts ++ drafts));

  };

  # Convert the `pages` attribute set to a list and set a default layout
  pagesList =
    let list = (pagesToList pages);
    in map (setDefaultLayout templates.layout) list;


/* Site rendering

   This render the site, for custom needs it is possible to use the `preGen` and `postGen` hooks
*/

  # fecth the versions to create the documentations
  fetchStyx = version:
    import (fetchTarball "https://github.com/styx-static/styx/archive/${version}.tar.gz") { inherit pkgs; };

  styxVersions = rec {
    # mater
    dev = fetchStyx "master";
    # latest stable
    latest = v0-2-0;
    # All the stable versions from here
    v0-2-0 = fetchStyx "v0.2.0";
    v0-1-0 = fetchStyx "v0.1.0";
  };

in generateSite {
  inherit files pagesList;

  # generating all versions documentation
  postGen = ''
    ${concatStringsSep "\n" (mapAttrsToList (version: styx: ''
      cp ${styx}/share/doc/styx/index.html $out/documentation-${version}.html
    '') styxVersions)}
    cp ${styxVersions.latest}/share/doc/styx/index.html $out/documentation.html
  '';
}
