{ templates, lib, pages, ... }:
with lib;
normalTemplate (page: ''
  <div class="container">
    ${(templates.post.full ((head pages.posts.list) // { embed = true; })).content}

    ${optionalString ((length pages.posts.list) >1) ''
      <div class="container article-archives">
      ${mapTemplate templates.post.list (drop 1 pages.posts.list)}
      </div>
    ''}
  </div>
'')
