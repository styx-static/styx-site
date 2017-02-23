{ lib, templates, ... }:
with lib;
normalTemplate(theme: ''
  <div class="container theme-full">
  <h1 class="text-capitalize">${theme.title}</h1>

  ${templates.theme.meta theme}
  ${templates.theme.conf theme}
  </div>
'')
