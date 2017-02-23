{ templates, lib, ... }:
page:
with lib;
''
  <article class="article-list">
    ${templates.tag.ilink {
      to = page;
      content = ''
        <strong>${templates.post.draft-icon page}${page.title}</strong>
        <time datetime="${(parseDate page.date).T}">${(parseDate page.date).date.num}</time>
      '';
    }}
  </article>
''
