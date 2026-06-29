# M3EOptionsMenu — Material 3 Expressive options menu

A floating action menu: a trigger icon that opens a panel of actions in an overlay.
Built because `m3e_core`'s `M3EDropdownMenu` is a value-**selector field** (chips, search,
multi-select), not an **action menu** — there was no ready component for "kebab → run an action".

File: `lib/ui/widgets/m3e_options_menu.dart`

## Why it looks/behaves the way it does

- **Floating**, not inline: rendered through `OverlayPortal` and positioned with
  `CompositedTransformFollower` linked to the trigger, so it overlays content and follows the
  button on scroll/resize. A full-screen translucent `Listener` dismisses it on outside tap.
- **Auto-flip**: opens downward, or above the trigger when there isn't enough room below
  (measured from the trigger's `RenderBox` against the viewport).
- **M3 Expressive motion**: spring open/close via the `motor` package
  (`SingleMotionController`), animating scale (0.82 → 1.0) and opacity from the anchored corner.
  Open uses `M3EMotion.expressiveSpatialDefault`, close uses `M3EMotion.expressiveEffectsFast`.
- **M3E surface**: `surfaceContainerHigh` panel, 24px radius, `outlineVariant` hairline border,
  soft shadow; items use `onSurface`, destructive items use the `error` role.

## Usage

```dart
M3EOptionsMenu(
  tooltip: context.t.activity.options,
  actions: [
    M3EMenuAction(
      icon: Icons.sync_rounded,
      label: 'Reconnect',
      onSelected: () => controller.redial(folderId, peerId),
    ),
    M3EMenuAction(
      icon: Icons.delete_outline_rounded,
      label: 'Remove',
      onSelected: onDelete,
      destructive: true,
    ),
  ],
)
```

## API

`M3EOptionsMenu`
- `actions` (required): `List<M3EMenuAction>` rendered top-to-bottom.
- `icon`: trigger glyph, default `Icons.more_vert_rounded`.
- `tooltip`: trigger tooltip.
- `width`: panel width, default `240`.
- `openMotion` / `closeMotion`: `M3EMotion` springs for the open/close transitions.

`M3EMenuAction`
- `icon`, `label`, `onSelected` (required); `destructive` (default `false`) tints the item with
  the `error` color role. Selecting an action closes the menu, then runs `onSelected`.

## First use

`ActivityEventMenu` (`lib/ui/widgets/activity_event_tile.dart`) — the desktop/side-rail layout of
the Activity screen, where each log row offers its contextual action (reconnect / resolve /
reveal) plus delete. The compact layout uses swipe gestures instead.
