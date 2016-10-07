{ pkgs ? import <nixpkgs> {}
, previewMode ? false
, siteUrl ? null
, lastChange ? ""
, styxVersion ? "master"
}@args:

let lib = import ./lib pkgs;
in with lib;

let

  conf = overrideConf (import ./conf.nix) args;

  state = { inherit lastChange; };

  loadTemplate = loadTemplateWithEnv genericEnv;

  genericEnv = { inherit conf state lib templates; };

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

  # Template declarations
  templates = {

    layout  = loadTemplateWithEnv 
                (genericEnv // { inherit navbar; feed = pages.feed; })
                "layout.nix";

    index   = loadTemplate "index.nix";

    news    = loadTemplate "news.nix";

    feed    = loadTemplate "feed.nix";

    navbar = {
      main = loadTemplate "navbar.main.nix";
      brand = loadTemplate "navbar.brand.nix";
    };

    post = {
      full     = loadTemplate "post.full.nix";
      list     = loadTemplate "post.list.nix";
      atomList = loadTemplate "post.atom-list.nix";
    };

  };

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
      posts = getPosts conf.postsDir "posts";
      drafts = optionals previewMode (getDrafts conf.draftsDir "drafts");
      preparePosts = p: p // { template = templates.post.full; };
    in sortPosts (map preparePosts (posts ++ drafts));

  };

  # Convert the `pages` attribute set to a list and set a default layout
  pageList =
    let list = (pagesToList pages);
    in map (setDefaultLayout templates.layout) list;

  # fecth the versions to create the documentations
  fetchStyx = version:
    import (fetchTarball "https://github.com/styx-static/styx/archive/${version}.tar.gz") { inherit pkgs; };

  styxVersions = rec {
    # mater
    dev = fetchStyx "master";
    # latest stable
    latest = v0-1-0;
    # All the stable versions from here
    v0-1-0 = fetchStyx "v0.1.0";
  };

in generateSite {
  inherit conf;

  pages = pageList;

  # generating all versions documentation
  postGen = ''
    ${concatStringsSep "\n" (mapAttrsToList (version: styx: ''
      cp ${styx}/share/doc/styx/index.html $out/documentation-${version}.html
    '') styxVersions)}
    cp ${styxVersions.latest}/share/doc/styx/index.html $out/documentation.html
  '';
}
