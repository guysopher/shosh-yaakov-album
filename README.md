# Album flipbook

A private-review website for Shosh and Yaakov's 50th-anniversary print album.
It displays the final front cover, 48 individual page leaves, and back cover in
a proportioned book viewer. Both sides of every turning leaf are decoded before
interaction, so the reverse page is present throughout the turn. The print
masters remain outside this site; `assets/` contains smaller screen-ready
derivatives only.

Each leaf mirrors one independently composed print page. Images never cross the
fold, every interior page contains photography, and the inner 140 px of each
printed page is reserved for the non-image center exclusion.

## Local preview

```sh
python3 -m http.server 4173
```

Open <http://localhost:4173>. Use the on-screen arrows, the left and right
arrow keys, Page Up/Page Down, or horizontal touch swipes.

## GitHub Pages

This directory is ready to become the root of a GitHub repository. The included
workflow deploys it when the repository's Pages source is set to **GitHub
Actions** and a commit reaches `main`. Because the site contains private family
photographs, confirm the repository and Pages visibility before publishing it.

## Source assets

- Covers: `../output/covers/`
- Print spreads: `../output/spreads/`
- Web derivatives: `assets/`

Rebuild the web derivatives with `./scripts/build-web-assets.sh`.
Validate the static package with `./scripts/verify-site.sh`.

## Page-turn engine

The viewer vendors StPageFlip 2.0.7 under its MIT license. Its browser bundle
and license are kept in `vendor/`; there is no runtime CDN dependency.
