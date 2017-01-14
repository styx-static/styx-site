{ pages, templates, ... }:
args:
templates.tag.link-atom {
  href = templates.purl pages.feed;
}
