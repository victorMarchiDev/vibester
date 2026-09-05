import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:mobile/providers/events/events_list_provider.dart';
import 'package:mobile/providers/place/place_list_provider.dart';
import 'package:mobile/screens/favorites/I_will_go_screen.dart';
import 'package:mobile/screens/favorites/favorites_screen.dart';
import 'package:mobile/screens/favorites/notifications_tab.dart';
import 'package:mobile/theme/app_motion.dart';
import 'package:mobile/theme/theme_extensions.dart';
import 'package:mobile/utils/divider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UserFavoritesScreen extends StatefulWidget {
  const UserFavoritesScreen({super.key});

  @override
  State<UserFavoritesScreen> createState() => _UserFavoritesScreenState();
}

class _UserFavoritesScreenState extends State<UserFavoritesScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsListProvider>().fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      FavoritesScreen(),
      IWillGoScreen(),
      NotificationsTab(),
    ];
    final event = Provider.of<EventsListProvider>(context);
    final places = Provider.of<PlaceListProvider>(context);

    int lugaresFavoritos = places.favorites.length;
    int eventosConfirmados = event.favorites.length;

    return Scaffold(
      backgroundColor: context.colors.noturno,
      appBar: AppBar(
        backgroundColor: context.colors.navy,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/img/logo/tipografia.png',
          height: 30,
          fit: BoxFit.contain,
        ),
      ),
      body: RefreshIndicator(
        color: context.colors.brasa,
        onRefresh: () => Future.wait([
          context.read<PlaceListProvider>().fetchPlaces(force: true),
          context.read<EventsListProvider>().fetchEvents(force: true),
        ]),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 15,
                  left: 16,
                  right: 16,
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        children: [
                          Text(
                            "Sua Vibe",
                            style: context.typography.headlineMedium.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Lugares que você curte e eventos interessados",
                          style: context.typography.labelMedium.copyWith(
                            color: context.colors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: context.colors.navy,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.colors.brasa,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.favorite_outline,
                              color: context.colors.brasa,
                              fontWeight: FontWeight(20),
                            ),
                          ),
                          Container(margin: EdgeInsets.only(left: 5)),
                          Container(
                            margin: const EdgeInsets.only(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      lugaresFavoritos.toString(),
                                      style: context.typography.titleMedium
                                          .copyWith(
                                            color: context.colors.textPrimary,
                                            fontSize: 15,
                                          ),
                                    ),
                                    Text(
                                      " LUGARES",
                                      style: context.typography.titleMedium
                                          .copyWith(
                                            color: context.colors.textDisabled,
                                            fontSize: 15,
                                          ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "FAVORITOS",
                                  style: context.typography.pixelBadge.copyWith(
                                    color: context.colors.textDisabled,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.colors.brasa,
                                width: 1,
                              ),
                            ),
                            child: Transform.rotate(
                              angle: -0.5,
                              child: FaIcon(
                                FontAwesomeIcons.ticket,
                                color: context.colors.brasa,
                                size: 21,
                              ),
                            ),
                          ),
                          Container(margin: EdgeInsets.only(left: 5)),
                          Container(
                            margin: const EdgeInsets.only(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      eventosConfirmados.toString(),
                                      style: context.typography.titleMedium
                                          .copyWith(
                                            color: context.colors.textPrimary,
                                            fontSize: 15,
                                          ),
                                    ),
                                    Text(
                                      " EVENTOS",
                                      style: context.typography.titleMedium
                                          .copyWith(
                                            color: context.colors.textDisabled,
                                            fontSize: 15,
                                          ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "CONFIRMADOS",
                                  style: context.typography.pixelBadge.copyWith(
                                    color: context.colors.textDisabled,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              _FavoritesTabBar(
                labels: const ['Favoritos', 'Vou ir', 'Notificações'],
                currentIndex: _currentIndex,
                onChanged: (index) => setState(() => _currentIndex = index),
              ),

              MyDivider(height: 1, width: double.infinity),
              tabs[_currentIndex],
            ],
          ),
        ),
      ),
    );
  }
}

/// Abas com um indicador que mede a posição de cada rótulo e desliza até lá
/// (spring), em vez de simplesmente trocar de "some/aparece" ao clicar.
class _FavoritesTabBar extends StatefulWidget {
  final List<String> labels;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _FavoritesTabBar({
    required this.labels,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  State<_FavoritesTabBar> createState() => _FavoritesTabBarState();
}

class _FavoritesTabBarState extends State<_FavoritesTabBar>
    with SingleTickerProviderStateMixin {
  static const _indicatorWidth = 24.0;

  final _stackKey = GlobalKey();
  late final List<GlobalKey> _labelKeys = List.generate(
    widget.labels.length,
    (_) => GlobalKey(),
  );

  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: 1,
    lowerBound: -0.3,
    upperBound: 1.3,
  );

  double? _fromX;
  double? _toX;
  bool _measured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _snapToCurrent());
  }

  @override
  void didUpdateWidget(covariant _FavoritesTabBar old) {
    super.didUpdateWidget(old);
    if (widget.currentIndex != old.currentIndex) {
      _animateTo(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? _measureCenterX(int index) {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final labelBox =
        _labelKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null ||
        labelBox == null ||
        !stackBox.hasSize ||
        !labelBox.hasSize) {
      return null;
    }
    final topLeft = labelBox.localToGlobal(Offset.zero, ancestor: stackBox);
    return topLeft.dx + labelBox.size.width / 2;
  }

  void _snapToCurrent() {
    final center = _measureCenterX(widget.currentIndex);
    if (center == null || !mounted) return;
    setState(() {
      _fromX = center;
      _toX = center;
      _measured = true;
      _controller.value = 1;
    });
  }

  void _animateTo(int index) {
    final target = _measureCenterX(index);
    if (target == null) return;

    final t = _controller.value.clamp(0.0, 1.0);
    final current = (_fromX != null && _toX != null)
        ? lerpDouble(_fromX!, _toX!, t)!
        : target;

    setState(() {
      _fromX = current;
      _toX = target;
    });

    if (context.reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.value = 0;
      _controller.animateWith(
        SpringSimulation(AppMotion.springSmooth, 0, 1, 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reposiciona no próximo frame se o layout mudou (ex.: rotação, texto
    // maior por acessibilidade) sem depender de o índice ter mudado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _fromX != null) return;
      _snapToCurrent();
    });

    return Stack(
      key: _stackKey,
      clipBehavior: Clip.none,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.labels.length, (index) {
            final isActive = widget.currentIndex == index;
            return GestureDetector(
              onTap: () => widget.onChanged(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  key: _labelKeys[index],
                  children: [
                    Text(
                      widget.labels[index],
                      style: TextStyle(
                        color: isActive
                            ? context.colors.textPrimary
                            : context.colors.textDisabled,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Espaço reservado — o traço em si é o indicador
                    // flutuante abaixo, não mais condicional por aba.
                    const SizedBox(height: 3),
                  ],
                ),
              ),
            );
          }),
        ),
        if (_measured)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final centerX = lerpDouble(_fromX!, _toX!, t)!;
              return Positioned(
                left: centerX - _indicatorWidth / 2,
                bottom: 0,
                child: Container(
                  height: 3,
                  width: _indicatorWidth,
                  decoration: BoxDecoration(
                    color: context.colors.brasa,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
