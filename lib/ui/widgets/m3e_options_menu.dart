import 'package:declar_ui/declar_ui.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:motor/motor.dart';

/// A single selectable action inside an [M3EOptionsMenu].
class M3EMenuAction {
  const M3EMenuAction({
    required this.icon,
    required this.label,
    required this.onSelected,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onSelected;
  final bool destructive;
}

/// A Material 3 Expressive options menu: a trigger icon that opens a floating
/// panel of [M3EMenuAction]s in an overlay.
///
/// The panel floats over content via [OverlayPortal] + [CompositedTransformFollower],
/// anchored to the trigger, flips above when there is not enough room below, and
/// springs open/closed with `motor` motion. Tapping outside dismisses it.
class M3EOptionsMenu extends StatefulWidget {
  const M3EOptionsMenu({
    super.key,
    required this.actions,
    this.icon = Icons.more_vert_rounded,
    this.tooltip,
    this.width = 240,
    this.openMotion = M3EMotion.expressiveSpatialDefault,
    this.closeMotion = M3EMotion.expressiveEffectsFast,
  });

  final List<M3EMenuAction> actions;
  final IconData icon;
  final String? tooltip;
  final double width;
  final M3EMotion openMotion;
  final M3EMotion closeMotion;

  @override
  State<M3EOptionsMenu> createState() => _M3EOptionsMenuState();
}

class _M3EOptionsMenuState extends State<M3EOptionsMenu>
    with SingleTickerProviderStateMixin {
  final _link = LayerLink();
  final _portal = OverlayPortalController();
  late final SingleMotionController _ctrl = SingleMotionController(
    motion: widget.openMotion.toMotion(),
    vsync: this,
  );
  bool _open = false;
  bool _showOnTop = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() => _open ? _close() : _show();

  void _show() {
    _open = true;
    _resolveDirection();
    _ctrl.motion = widget.openMotion.toMotion();
    _portal.show();
    _ctrl.animateTo(1);
  }

  void _close() {
    if (!_open) return;
    _open = false;
    _ctrl.motion = widget.closeMotion.toMotion();
    _ctrl.animateTo(0).whenComplete(() {
      if (mounted && !_open) _portal.hide();
    });
  }

  void _select(M3EMenuAction action) {
    _close();
    action.onSelected();
  }

  void _resolveDirection() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final media = MediaQuery.of(context);
    final dy = box.localToGlobal(Offset.zero).dy;
    final below = media.size.height - dy - box.size.height;
    final estimate = widget.actions.length * 52 + 16;
    _showOnTop = below < estimate + media.padding.bottom && dy > below;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildOverlay,
        child: IconButton(
          tooltip: widget.tooltip,
          onPressed: _toggle,
          icon: Icon(widget.icon),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _close(),
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: _showOnTop ? Alignment.topRight : Alignment.bottomRight,
          followerAnchor: _showOnTop
              ? Alignment.bottomRight
              : Alignment.topRight,
          offset: Offset(0, _showOnTop ? -6 : 6),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              final t = _ctrl.value.clamp(0.0, 1.0);
              return Opacity(
                opacity: t,
                child: Transform.scale(
                  scale: 0.82 + 0.18 * t,
                  alignment: _showOnTop
                      ? Alignment.bottomRight
                      : Alignment.topRight,
                  child: child,
                ),
              );
            },
            child: _panel(context),
          ),
        ),
      ],
    );
  }

  Widget _panel(BuildContext context) {
    final colors = context.colors;
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: widget.width,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: .4),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: .22),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            for (final action in widget.actions)
              _MenuItem(action: action, onTap: () => _select(action)),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.action, required this.onTap});

  final M3EMenuAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = action.destructive ? colors.error : colors.onSurface;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(action.icon, size: 20, color: foreground),
              const SizedBox(width: 14),
              Expanded(
                child: Text(action.label)
                    .size(14)
                    .weight(.w700)
                    .color(foreground)
                    .maxLines(1)
                    .overflow(.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
