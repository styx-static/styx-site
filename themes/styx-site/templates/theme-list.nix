{ lib, templates, pages, ... }:
with lib;
lib.normalTemplate (page: ''
  <div class="container theme-list">
    ${mapTemplate (ts:
        ''<div class="row">''
      +  (mapTemplate templates.theme.preview ts)
      +  "</div>"
    ) (chunksOf 3 pages.themes)}
  </div>
'')
