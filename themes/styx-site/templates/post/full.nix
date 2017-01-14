{ lib, templates, ... }:
with lib;
normalTemplate (page: ''
  <div class="container">
    <article>
      <header class="article-header">
        ${if (page ? linkTitle) then ''
        <h1>${
          templates.tag.ilink {
            inherit page;
            content = page.title;
          }
        + (templates.post.draft-icon page)
        }</h1>
        '' else ''
        <h1>${page.title}${templates.post.draft-icon page}</h1>
        ''}
        <time datetime="${(parseDate page.date).T}">${(parseDate page.date).date.num}</time>
      </header>
      <div class="container">
      ${page.content}
      </div>
    </article>
  </div>
'')
