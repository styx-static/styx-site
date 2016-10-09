{ conf, lib, ... }:
with lib;
post:
let
  draftIcon = optionalString (attrByPath ["isDraft"] false post) "<span class=\"glyphicon glyphicon-file\"></span> ";
in
  ''
    <article class="article-list">
      <a href="${conf.siteUrl}/${post.href}">
        <strong>${draftIcon}${post.title}</strong>
        <time pubdate="pubdate" datetime="${post.timestamp}">${post.timestamp}</time>
      </a>
    </article>
  ''
