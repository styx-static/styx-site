{ lib, templates, pages, ... }:
with lib;
normalTemplate ''
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
    <p>nix-shell -p styx</p>
    <p>styx new site mysite && cd mysite</p>
  </div>
  <p class="text-center">Then have a look at readme.md file or at the ${templates.tag.ilink { path = "/documentation.html"; content = "documentation"; }} to learn how to customize your site.</p>
  </div>
  <div class="top-news container">
  <h2>Latest News</h2>
    ${optionalString ((length pages.posts) >1) ''
      <div class="container article-archives">
      ${mapTemplate templates.post.list (take 3 pages.posts)}
      <div class="past-news">${templates.tag.ilink { page = pages.news; content = "Past News"; }}</div>
      </div>
    ''}
  </div>
''
