# filepunch.dev

The website for [Filepunch](https://github.com/filepunch/filepunch), served by GitHub Pages at <https://filepunch.dev>.

Plain HTML, one stylesheet, no build step, no JavaScript, no external fonts, no tracking. The PNG images are drawn once by a script and committed (see Images). Only the `site/` directory is published. The rest of this repository is not part of the website.

| File | Purpose |
| --- | --- |
| `site/index.html` | the page |
| `site/style.css` | the stylesheet, light and dark via `prefers-color-scheme` |
| `site/404.html` | served by Pages for unknown paths |
| `site/CNAME` | a written record of the custom domain, `filepunch.dev`. GitHub ignores this file when a workflow publishes the site. The domain itself is set in the repository settings (see Publishing). |
| `site/favicon.svg` | the browser tab icon: the green dot from the page header, in the darker green when the browser is in light mode |
| `site/favicon.png` | the same icon as a 32 x 32 picture, for browsers that cannot show SVG icons |
| `site/apple-touch-icon.png` | the 180 x 180 icon a phone shows when someone adds the site to the home screen |
| `site/social.png` | the 1200 x 630 picture that link previews show, for example in Slack, LinkedIn, X or Mastodon |
| `site/robots.txt` | tells search engines they may read the whole site, and where the sitemap is |
| `site/sitemap.xml` | the list of pages for search engines. The site has one page. |
| `images/` | the sources of the three PNG files above, and `render.sh`, which draws them (see Images) |
| `.github/workflows/pages.yml` | publishes `site/` to Pages on every push to `main` |

The wording is drawn from the code repository's `README.md`, `docs/security.md`, `docs/protocol.md`, `docs/signaling.md` and `examples/`. When those change, change the page; the site must not claim anything the docs do not.

Some of the wording appears more than once. The `description` and `og:description` lines in the head of `index.html` repeat the tagline and the lead. The social card (`images/social.html`, drawn into `site/social.png`) and the `og:image:alt` line repeat three things: the tagline, the first line of the lead, and the first two parts of the badge above the title, "Coming soon · Open source". When you change one, change the others. After a change to the card, run `images/render.sh` again (see Images).

## Link previews

The `og:` lines (Open Graph tags) and the `twitter:card` line in the head of `index.html` tell Slack, LinkedIn, X, Mastodon and other apps which title, text and picture to show when someone shares a link to the site. X reads the `og:` lines too; `twitter:card` asks it to show the large picture. The picture must be a full `https://` address. `rel="canonical"` tells search engines the one address of the page.

## Images

The three PNG files in `site/` are drawn from sources in `images/`:

```sh
sh images/render.sh
```

The script needs Google Chrome or Chromium and Python 3 with Pillow (the Python imaging library). Chrome draws each source, then Pillow cuts the file down to a few colors so it stays small. Run it after you change `images/social.html`, `images/icon.html` or `site/favicon.svg`, look at the new pictures, and commit them with the change. The text in `social.png` uses the fonts of the machine that runs the script; it was drawn with Cantarell, which is in the site's font list.

## Publishing

In the repository settings, under Pages:

- set Source to "GitHub Actions";
- set Custom domain to `filepunch.dev`. This setting tells GitHub the domain, not the `CNAME` file.

The workflow uploads `site/` as it is and publishes it on every push to `main`. GitHub does not run Jekyll (the tool it uses to build sites published straight from a branch) for a workflow like this one, so the site needs no `.nojekyll` file.

Every file in `site/` is published, including files whose names start with a dot, such as a future `site/.well-known/security.txt`. The upload step leaves those out unless it is given `include-hidden-files: true`, so keep that line in the workflow. After a deploy that adds such a file, open its address in a browser to check that it is there.

## Checking a change locally

```sh
python3 -m http.server 8000 --directory site
```

Open <http://localhost:8000>. Check the page at a phone width (16 px side gutters, no horizontal scroll), in light and dark mode, and keep `site/` under 60 KB.
