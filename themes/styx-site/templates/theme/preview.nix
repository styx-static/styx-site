{ lib, templates, ... }:
theme:
with lib;
''
<div class="col-md-4">
<div class="theme-thumbnail">
  <h1>${templates.tag.ilink { page = theme; content = theme.meta.name; }}</h1>
  ${templates.tag.ilink { page = theme; content = ''<img class="img-responsive" src="${templates.url theme.meta.thumbnailPath}" />''; }}
</div>
</div>
''
