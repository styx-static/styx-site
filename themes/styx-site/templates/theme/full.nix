{ lib, templates, ... }:
with lib;
normalTemplate(theme: ''
  <div class="container theme-full">
  <h1 class="text-capitalize">${theme.title}</h1>

  ${optionalString (theme.meta ? description)
    ''<div class="description">${asciidocToHtml theme.meta.description}</div>''}

  ${optionalString (theme.meta ? longDescription)
    ''<div class="longDescription">${asciidocToHtml theme.meta.longDescription}</div>''}

  ${optionalString (theme.meta ? license)
    ''<p class="license">License: <a href="${theme.meta.license.url}">${theme.meta.license.fullName}</a></p>''}

  ${optionalString ((theme.meta ? demoPage) || (theme.meta ? homepage)) ''<p class="links">
  ${optionalString (theme.meta ? demoPage)
    ''<a href="${theme.meta.demoPage}" class="btn btn-info">${templates.icon.font-awesome "desktop"} Demo</a> ''}
  ${optionalString (theme.meta ? homepage)
    ''<a href="${theme.meta.homepage}" class="btn btn-info">${templates.icon.font-awesome "home"} Homepage</a>''}
  </p>''}

  ${optionalString (theme.meta ? screenshotPath)
    ''<img class="img-responsive center-block" src="${templates.url theme.meta.screenshotPath}" />''}

  ${optionalString (theme.docs != null) (
    ''<div class="conf">''
  + (templates.bootstrap.panel {
      type    = "primary";
      heading = "Configuration interface";
      content = mapTemplate (data:
        let
          isSet = x: hasAttr x data && data."${x}" != null;
          descHtml = ''<dt>Description:</dt><dd>${asciidocToHtml data.description}</dd>'';
          typeHtml = optionalString (isSet "type")
            ''<dt>Type:</dt><dd>${data.type}</dd>'';
          defaultHtml = optionalString (isSet "default")
            ''<dt>Default:</dt><dd><code>${toJSON data.default}</code></dd>'';
          exampleHtml = optionalString (isSet "example")
            ''<dt>Example:</dt><dd><code>${toJSON data.example}</code></dd>'';
        in ''
          <div class="list-group-item">
            <p><strong>${data.pathString}</strong></p>
            <dl class="dl-horizontal">${descHtml + typeHtml + defaultHtml + exampleHtml}</dl>
          </div>''

      ) (mkDocs { inherit (theme) docs decls; });
     })
   + "</div>"
  )}
  
  </div>
'')
