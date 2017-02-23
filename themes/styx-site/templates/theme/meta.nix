{ lib, templates, ... }:
theme:
with lib;
''
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
''
