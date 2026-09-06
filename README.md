# Album flipbook

A public review website for Shosh and Yaakov's 50th-anniversary print album.
It displays the final front cover, 48 individual page leaves, and back cover in
a proportioned book viewer. Both sides of every turning leaf are decoded before
interaction, so the reverse page is present throughout the turn. The print
masters remain outside this site; `assets/` contains smaller screen-ready
derivatives only.

Each leaf mirrors one independently composed print page. Images never cross the
fold, every interior page contains photography, and the inner 140 px of each
printed page is reserved for the non-image center exclusion.

The album content combines large foreground family photographs with authentic
period imagery from the archive. Twenty spreads are family-led and four are
chronological atmosphere spreads; only years appear inside the book.

## Local preview

```sh
python3 -m http.server 4173
```

Open <http://localhost:4173>. Use the on-screen arrows, the left and right
arrow keys, Page Up/Page Down, or horizontal touch swipes.

## GitHub Pages

The included workflow deploys through GitHub Pages from `main` and from the
active album-review branch. The repository and its family photographs are
public.

## Source assets

- Covers: `../output/covers/`
- Print spreads: `../output/spreads/`
- Web derivatives: `assets/`

Rebuild the web derivatives with `./scripts/build-web-assets.sh`.
Validate the static package with `./scripts/verify-site.sh`.

## Page-turn engine

The viewer vendors StPageFlip 2.0.7 under its MIT license. Its browser bundle
and license are kept in `vendor/`; there is no runtime CDN dependency.
