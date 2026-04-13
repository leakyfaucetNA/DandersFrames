# Dispel Indicator — Pixel Glow Feature

## Summary

Added a **Pixel Glow** option to the Dispel Overlay. When enabled, a multi-layer backdrop glow appears around the unit frame using the existing GLOW style from the Highlights/AuraDesigner system. The glow honours the existing dispel colours and is fully independent from the existing border/gradient/pulse options.

---

## Files Changed

### Config.lua
Added 5 new defaults to both `PartyDefaults` and `RaidDefaults` under the Dispel Overlay section:

```lua
dispelPixelGlowAlpha     = 0.8,
dispelPixelGlowEnabled   = false,
dispelPixelGlowOffset    = 0,
dispelPixelGlowSpeed     = 0.5,
dispelPixelGlowThickness = 2,
```

### Features/Dispel.lua
Four edit points:

1. **`CreateDispelOverlay`** — Creates `overlay.pixelGlowFrame` parented to the **unit frame** (not the overlay), so its pulse animation is independent of the overlay's own pulse. Has dummy `topLine`/`bottomLine`/`leftLine`/`rightLine` textures to satisfy `DF.ApplyHighlightStyle`. Stores `dfGlowFadeOut` / `dfGlowFadeIn` animation references and a `dfGlowSpeed` cache so durations can be updated without recreating the group.

2. **`LayoutStateChanged` / `CacheLayoutState`** — Tracks `dispelPixelGlowEnabled`, `dispelPixelGlowThickness`, and `dispelPixelGlowOffset` so the expensive layout path only fires when those settings actually change.

3. **`ApplyOverlayLayout`** — Calls `DF.ApplyHighlightStyle(glowFrame, "GLOW", thickness, offset, 1, 1, 1, 1)` here (full layer repositioning), using white as a placeholder colour. The real dispel colour is applied immediately after by `ShowOverlayWithRGB`.

4. **`ShowOverlayWithRGB`** — Calls `DF.UpdateHighlightStyleColor` (colour-only, no repositioning) on every invocation. Animation speed is only stopped/restarted when `dfGlowSpeed` differs from the current setting. `HideOverlay` stops the animation and hides the frame.

### Core.lua
- **`LightweightUpdateDispelOverlay`** — Calls `DF.ApplyHighlightStyle` (full update, fine here — only runs on slider drag).
- **`LightweightUpdateDispelColors`** — Calls `DF.UpdateHighlightStyleColor` (cheap colour-only path, test mode only).

### Options/Options.lua
New **Pixel Glow** settings group added between the Border group and the Gradient group (column 1):
- `Show Pixel Glow` checkbox
- `Thickness` slider (1–8) — hidden when glow disabled
- `Glow Offset` slider (−4 to 8) — hidden when glow disabled
- `Glow Speed` slider (0.1–2.0) — hidden when glow disabled
- `Glow Opacity` slider (0.1–1.0) — hidden when glow disabled

### Locales/enUS.lua
5 new strings added alphabetically:
- `L["Glow Offset"] = true`
- `L["Glow Opacity"] = true`
- `L["Glow Speed"] = true`
- `L["Pixel Glow"] = true`
- `L["Show Pixel Glow"] = true`

### ExportCategories.lua
5 new keys added to the dispel export block after `dispelAnimateSpeed`:
- `dispelPixelGlowEnabled`
- `dispelPixelGlowThickness`
- `dispelPixelGlowOffset`
- `dispelPixelGlowSpeed`
- `dispelPixelGlowAlpha`

---

## Performance Notes

| Path | Cost |
|------|------|
| **Combat / hot path** | `UpdateHighlightStyleColor` only — 4× `SetBackdropBorderColor`, no allocations, no repositioning |
| **Layout change** (settings adjusted) | `ApplyHighlightStyle` repositions 4 `BackdropTemplate` frames — identical cost to the Highlights/AuraDesigner system, only fires when layout settings change |
| **Animation speed update** | Guarded by `dfGlowSpeed` cache — stop/restart only when speed actually changes, not every frame |
| **Glow disabled** | Zero overhead beyond a single boolean check per frame |

The glow frame is parented to the unit frame (not the overlay), so the overlay's own `dispelAnimate` pulse does not affect it. Each can animate independently.

---

## Settings Reference

| Key | Default | Range | Description |
|-----|---------|-------|-------------|
| `dispelPixelGlowEnabled` | `false` | — | Enable the pixel glow layer |
| `dispelPixelGlowThickness` | `2` | 1–8 | Edge size of each glow layer |
| `dispelPixelGlowOffset` | `0` | −4 to 8 | Base inset; negative pulls glow inside the frame, positive pushes it further out |
| `dispelPixelGlowSpeed` | `0.5` | 0.1–2.0 | Half-period (seconds) of the glow pulse animation; higher = slower |
| `dispelPixelGlowAlpha` | `0.8` | 0.1–1.0 | Opacity of the glow |
