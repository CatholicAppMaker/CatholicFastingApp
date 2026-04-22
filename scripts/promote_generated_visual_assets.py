#!/usr/bin/env python3
"""Promote reviewed generated visual assets into production app/social paths."""
from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageOps
import json

ROOT = Path('/Users/kevpierce/Desktop/CatholicFastingApp')
ASSETS = ROOT / 'CatholicFastingApp/Assets.xcassets'
GENERATED = ROOT / 'design/generated'
ACCEPTED_ICONS = GENERATED / 'accepted/icons'
FALLBACKS = ROOT / 'CatholicFastingApp/IconFallbacks'
SOCIAL = ROOT / 'release/social'

ICON_MASTER_BY_SET = {
    'AppIcon.appiconset': 'AppIcon-master-1024.png',
    'AppIconAdvent.appiconset': 'AppIconAdvent-master-1024.png',
    'AppIconChristmas.appiconset': 'AppIconChristmas-master-1024.png',
    'AppIconLent.appiconset': 'AppIconLent-master-1024.png',
    'AppIconEaster.appiconset': 'AppIconEaster-master-1024.png',
}

FALLBACK_BY_SET = {
    'AppIconAdvent.appiconset': 'AppIconAdvent',
    'AppIconChristmas.appiconset': 'AppIconChristmas',
    'AppIconLent.appiconset': 'AppIconLent',
    'AppIconEaster.appiconset': 'AppIconEaster',
}


def icon_pixels(entry: dict) -> int:
    size = entry.get('size', '0x0').split('x')[0]
    scale = entry.get('scale', '1x').replace('x', '')
    return round(float(size) * float(scale))


def save_cover(src: Path, dst: Path, size: tuple[int, int], *, quality: int = 95) -> None:
    im = Image.open(src).convert('RGB')
    out = ImageOps.fit(im, size, method=Image.Resampling.LANCZOS, centering=(0.5, 0.5))
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.suffix.lower() in {'.jpg', '.jpeg'}:
        out.save(dst, quality=quality, optimize=True)
    else:
        out.save(dst, optimize=True)


def promote_icons() -> None:
    for icon_set, master_name in ICON_MASTER_BY_SET.items():
        master_path = ACCEPTED_ICONS / master_name
        master = Image.open(master_path).convert('RGB')
        contents_path = ASSETS / icon_set / 'Contents.json'
        contents = json.loads(contents_path.read_text())
        for entry in contents.get('images', []):
            filename = entry.get('filename')
            if not filename:
                continue
            px = icon_pixels(entry)
            out = ImageOps.fit(master, (px, px), method=Image.Resampling.LANCZOS, centering=(0.5, 0.5))
            out.save(ASSETS / icon_set / filename, optimize=True)

    for icon_set, fallback_name in FALLBACK_BY_SET.items():
        master = Image.open(ACCEPTED_ICONS / ICON_MASTER_BY_SET[icon_set]).convert('RGB')
        for px in (120, 152):
            out = ImageOps.fit(master, (px, px), method=Image.Resampling.LANCZOS, centering=(0.5, 0.5))
            out.save(FALLBACKS / f'{fallback_name}-{px}.png', optimize=True)


def promote_in_app_art() -> None:
    gpt2 = GENERATED / 'gpt-image-2-pass/candidates'
    save_cover(gpt2 / 'hero/hero-sacred-gpt2-b.png', ASSETS / 'HeroSacred.imageset/hero-sacred.jpg', (1600, 1000))
    save_cover(gpt2 / 'guidance/guidance-sacred-gpt2-b.png', ASSETS / 'GuidanceSacred.imageset/guidance-sacred.jpg', (1600, 1000))
    save_cover(
        gpt2 / 'premium/premium-support-gpt2-b.png',
        ASSETS / 'SacredScriptureCandle.imageset/scripture-candle.png',
        (1600, 1000),
    )


def promote_social() -> None:
    header = GENERATED / 'gpt-image-2-pass/candidates/social/social-header-gpt2-a.png'
    icon = ACCEPTED_ICONS / 'AppIcon-master-1024.png'
    save_cover(header, SOCIAL / 'x-header-1500x500.png', (1500, 500))
    save_cover(header, SOCIAL / 'x-header-1500x500-alt.png', (1500, 500))
    save_cover(icon, SOCIAL / 'x-profile-400.png', (400, 400))


def main() -> None:
    promote_icons()
    promote_in_app_art()
    promote_social()
    print('Promoted generated icons, in-app art, fallbacks, and social assets.')


if __name__ == '__main__':
    main()
