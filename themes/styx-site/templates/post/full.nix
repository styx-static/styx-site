{ lib, templates, conf, ... }:
with lib;
post:
let
  date = ''
    <time pubdate="pubdate" datetime="${post.timestamp}" class="text-right">${post.timestamp}</time>
  '';
  draftIcon = optionalString (attrByPath ["isDraft"] false post) " <span class=\"glyphicon glyphicon-pencil\"></span>";
  content = ''
    <div class="container">
      <article>
        <header class="article-header">
          ${if (post ? linkTitle) then ''
          <h1><a ${htmlAttr "href" "${conf.siteUrl}/${post.href}"}>${post.title}</a>${draftIcon}</h1>
          '' else ''
          <h1>${post.title}${draftIcon}</h1>
          ''}
          ${date}
        </header>
        <div class="container">
        ${post.content}
        </div>
      </article>
    </div>
  '';
in
  post // { inherit content; }
