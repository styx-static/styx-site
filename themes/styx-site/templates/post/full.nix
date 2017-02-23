env:

let template = { lib, templates, ... }:
  with lib;
  normalTemplate (page: ''
    <div class="container">
      <article>
        <header class="article-header">
          ${if (page ? embed) then ''
          <h1>${
            templates.tag.ilink {
              to = page;
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

      ${optionalString ( !(attrByPath ["embed"] false page) && (page ? pageList) ) (
        "<hr />"
      + (templates.bootstrap.pager { inherit (page.pageList) pages index; })
      )}
    </div>
  '');

in env.lib.documentedTemplate {
  inherit env template;
  description = "Post full template.";
}
