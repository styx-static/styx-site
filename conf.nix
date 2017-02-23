{

  # URL of the site, must be set to the url of the domain the site will be deployed
  siteUrl = "https://styx-static.github.io/styx-site";

  theme = {
    site.title = "Styx Static Site Generator";
    lib = {
      bootstrap.enable    = true;
      jquery.enable       = true;
      font-awesome.enable = true;
      highlightjs = {
        enable = true;
        style = "github";
        extraLanguages = [ "nix" ];
      };
    };
    services.google-analytics.trackingID = "UA-90618087-1";
  };

}
