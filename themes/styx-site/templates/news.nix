{ conf, templates, lib, ... }:
with lib;
page:

let
  content = 
    ''
      <div class="container">
        ${(templates.post.full ((head page.posts) // { linkTitle = true; })).content}

        ${optionalString ((length page.posts) >1) ''
          <div class="container article-archives">
          ${mapTemplate templates.post.list (drop 1 page.posts)}
          </div>
        ''}
      </div>
    '';
in
  page // { inherit content; }
