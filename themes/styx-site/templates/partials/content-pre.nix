{ templates, data, conf, ... }:
{ page }:
templates.bootstrap.navbar.default {
  brand = templates.tag.ilink { to = "/"; class = "navbar-brand"; content = conf.theme.site.title; };
  extraClasses = [ "navbar-fixed-top" ];
  content = [
    (templates.bootstrap.navbar.nav {
      align = "right";
      items = data.navbar;
      currentPage = page;
    })
  ];
} 
