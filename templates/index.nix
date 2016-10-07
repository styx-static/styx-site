{ conf, templates, lib, ... }:
with lib;
page:

let
  content = 
    ''
      <div class="jumbotron">
        <div class="container">
        <h1>Styx</h1>
        <h2>The Purely Functional Static Site Generator.</h2>

        <p class="lead">
          Styx is a functional static site generator based on the <a href="http://nixos.org/nix/">Nix package manager.</a>
        </p>
        </div>
      </div>

      <div class="container quick-start">
      <h2>Quick Start</h2>
      <div class="console">
        <p>nix-shell -p $(nix-build https://github.com/styx-static/styx/archive/latest.tar.gz)</p>
        <p>styx new myblog</p>
        <p>cd myblog && styx serve</p>
      </div>
      <p class="text-center">Then have a look to the <a href="${conf.siteUrl}/documentation.html">documentation</a> to learn how to customize your site.</p>
      </div>
    '';
in
  page // { inherit content; }
