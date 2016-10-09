{ conf, lib, templates
, navbar ? false
, feed ? false
, ... }:

page:
with lib;
  ''
    <!DOCTYPE html>
    <html>
  
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width; initial-scale=1">
  
      <title>${page.title} - Styx Static Site Generator</title>
  
      ${optionalString (feed != false) ''
      <link
        href="${conf.siteUrl}/${feed.href}"
        type="application/atom+xml"
        rel="alternate"
        title="${conf.siteTitle}"
        />
      ''}
  
      <link
        rel="stylesheet"
        href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
        integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u"
        crossorigin="anonymous">

      <script
        src="https://code.jquery.com/jquery-3.1.1.min.js"
        integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8="
        crossorigin="anonymous"></script>

      <script
        src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
        integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa"
        crossorigin="anonymous"></script>

      <script src="https://use.fontawesome.com/8f4021a465.js"></script>

      <link
          rel="stylesheet"
          href="${conf.siteUrl}/style.css">
    </head>
  
    <body${optionalString (navbar != false) " ${htmlAttr "class" "with-navbar"}"}>
  
      ${if (navbar != false)
          then (templates.navbar.main navbar)
          else ''
            <header class="site-header">
              <div class="container wrapper">
                <a class="site-title" href="${conf.siteUrl}">${conf.siteTitle}</a>
              </div>
            </header>
          ''}

      ${page.content}

      <div class="navbar navbar-fixed-bottom" id="footer">
        <div class="container">
        <footer>
          <p class="text-center">2016 - <a href="https://github.com/styx-static/styx-site/">Made with Styx!</a></p>
        </footer>
        </div>
      </div>
  
    </body>
    </html>
  ''
