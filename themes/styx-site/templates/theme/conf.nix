{ lib, templates, ... }:
theme:
with lib;
optionalString (theme ? docs) (
  ''<div class="theme-conf">''
+ (templates.bootstrap.panel {
    heading = "Configuration interface";
    listGroup = "<ul class=\"list-group\">\n" + concatStringsSep "" (propMap (conf: data:
      let
        descHtml    = optionalString (data ? description) ''<dt>Description:</dt><dd>${asciidocToHtml data.description}</dd>'';
        typeHtml    = optionalString (data ? type)        ''<dt>Type:</dt><dd>${data.type}</dd>'';
        defaultHtml = optionalString (data ? default)     ''<dt>Default:</dt><dd><pre><code class="nix">${escapeHTML (prettyNix data.default)}</code></pre></dd>'';
        exampleHtml = optionalString (data ? example)     ''<dt>Example:</dt><dd><pre><code class="nix">${escapeHTML (prettyNix data.example)}</code></pre></dd>'';
      in ''
        <li class="list-group-item">
          <p><strong>${conf}</strong></p>
          <dl>${
            descHtml
          + typeHtml
          + defaultHtml
          + exampleHtml
          }</dl>
        </li>''
    ) (docText theme.docs)) + "</ul>\n";
   })
+ ''</div>'')
