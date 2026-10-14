# filepunch.dev

The website for [Filepunch](https://github.com/filepunch/filepunch), served by GitHub Pages at <https://filepunch.dev>.

Plain HTML, one stylesheet, no build step, no JavaScript, no external fonts, no tracking. Everything at the root of this repository is what gets served:

| File | Purpose |
| --- | --- |
| `index.html` | the page |
| `style.css` | the stylesheet, light and dark via `prefers-color-scheme` |
| `404.html` | served by Pages for unknown paths |
| `CNAME` | tells Pages the custom domain; must contain exactly `filepunch.dev` |
| `.nojekyll` | stops Pages from running Jekyll over the files |
| `.github/workflows/pages.yml` | deploys to Pages on every push to `main` |

The wording is drawn from the code repository's `README.md`, `docs/security.md`, `docs/protocol.md`, `docs/signaling.md` and `examples/`. When those change, change the page; the site must not claim anything the docs do not.

## Publishing

In the repository settings, Pages, set Source to "GitHub Actions". The workflow uploads the repository root and deploys it; the site is published on every push to `main`.


## Checking a change locally

```sh
python3 -m http.server 8000
```

Open <http://localhost:8000>. Check the page at a phone width (16 px side gutters, no horizontal scroll), in light and dark mode, and keep the whole directory under 60 KB.
