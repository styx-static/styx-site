{ conf, templates, lib, pages, ... }:
with lib;
page:

let
  content = 
    ''
      <div class="container">
        ${(templates.post.full ((head pages.posts) // { linkTitle = true; })).content}

        ${optionalString ((length pages.posts) >1) ''
          <div class="container article-archives">
          ${mapTemplate templates.post.list (drop 1 pages.posts)}
          </div>
        ''}
      </div>
    '';
in
  page // { inherit content; }
