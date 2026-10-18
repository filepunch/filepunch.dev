# filepunch.dev

The website for [Filepunch](https://github.com/filepunch/filepunch), served by GitHub Pages at <https://filepunch.dev>.

Plain HTML, one stylesheet, no build step, no JavaScript, no external fonts, no tracking. Only the `site/` directory is published. The rest of this repository is not part of the website.

| File | Purpose |
| --- | --- |
| `site/index.html` | the page |
| `site/style.css` | the stylesheet, light and dark via `prefers-color-scheme` |
| `site/404.html` | served by Pages for unknown paths |
| `site/CNAME` | a written record of the custom domain, `filepunch.dev`. GitHub ignores this file when a workflow publishes the site. The domain itself is set in the repository settings (see Publishing). |
| `.github/workflows/pages.yml` | publishes `site/` to Pages on every push to `main` |

The wording is drawn from the code repository's `README.md`, `docs/security.md`, `docs/protocol.md`, `docs/signaling.md` and `examples/`. When those change, change the page; the site must not claim anything the docs do not.

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
