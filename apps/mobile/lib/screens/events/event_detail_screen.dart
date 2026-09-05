import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/event/event_model.dart';
import 'package:mobile/providers/user/user_provider.dart';
import 'package:mobile/service/event/event_service.dart';
import 'package:mobile/theme/app_motion.dart';
import 'package:mobile/utils/app_progress_indicator.dart';
import 'package:mobile/utils/hero_tags.dart';
import 'package:mobile/widgets/cards/users/map_event.dart';
import 'package:mobile/widgets/indicators/lineup_indicator.dart';
import 'package:mobile/widgets/buttons/secundary_button.dart';
import 'package:mobile/widgets/buttons/tertiary_button.dart';
import 'package:mobile/widgets/motion/staggered_entrance.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_extensions.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel eventModel;

  const EventDetailScreen({super.key, required this.eventModel});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _eventService = EventService();
  late EventModel _event;
  bool _isTogglingPresence = false;

  @override
  void initState() {
    super.initState();
    _event = widget.eventModel;
    _carregarStatusDePresenca();
  }

  Future<void> _carregarStatusDePresenca() async {
    final userId = context.read<UserProvider>().user?.accountId;
    final eventId = _event.id;
    if (userId == null || eventId == null) return;

    final checkedIn = await _eventService.getCheckInStatus(
      eventId: eventId,
      userId: userId,
    );

    if (mounted) {
      setState(() => _event = _event.copyWith(isFavorite: checkedIn));
    }
  }

  Future<void> _alternarPresenca() async {
    final userId = context.read<UserProvider>().user?.accountId;
    final eventId = _event.id;
    if (userId == null || eventId == null || _isTogglingPresence) return;

    final confirmadoAntes = _event.isFavorite;
    setState(() {
      _isTogglingPresence = true;
      _event = _event.copyWith(
        isFavorite: !confirmadoAntes,
        totalConfirmed: confirmadoAntes
            ? _event.totalConfirmed - 1
            : _event.totalConfirmed + 1,
      );
    });

    try {
      if (confirmadoAntes) {
        await _eventService.checkOut(eventId: eventId, userId: userId);
      } else {
        await _eventService.checkIn(eventId: eventId, userId: userId);
      }
    } catch (e) {
      final is409 = e.toString().contains('409');
      // 409 significa que o backend já está no estado pra onde tentamos ir
      // (corrida com outra tela) — mantém a UI como está.
      if (!is409 && mounted) {
        setState(() {
          _event = _event.copyWith(
            isFavorite: confirmadoAntes,
            totalConfirmed: _event.totalConfirmed + (confirmadoAntes ? 1 : -1),
          );
        });
      }
    } finally {
      if (mounted) setState(() => _isTogglingPresence = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: context.colors.noturno,

      body: ListView(
        children: [
          //Header, imagem e título
          //===============================================================================
          SizedBox(
            height: size.height * 0.41,

            child: Stack(
              children: [
                //Imagen ocupando todo o espaço desse SizedBox
                Positioned.fill(
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          context.colors.noturno.withAlpha(255),
                        ],
                      ),
                    ),

                    //lugar da imagem
                    child: Hero(
                      tag: eventImageHeroTag(_event),
                      child: CachedNetworkImage(
                        imageUrl: _event.imageUrl,
                        fit: BoxFit.cover,
                        fadeInDuration: AppMotion.imageFade,
                        fadeOutDuration: AppMotion.imageFade,
                        placeholder: (_, _) =>
                            const Center(child: AppProgressIndicator()),
                        errorWidget: (_, _, _) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),

                //Botão de voltar
                Positioned(
                  top: 20,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: context.colors.darkGrey.withOpacity(0.8),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: context.colors.ambar,
                      ),
                    ),
                  ),
                ),

                //Botão de Compartilhar
                Positioned(
                  top: 20,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: context.colors.darkGrey.withOpacity(0.8),
                    child: IconButton(
                      onPressed: () {
                        //Ação de compartilhar
                      },
                      icon: Icon(
                        Icons.share,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ),

                //Titulo do evento e Tipo de evento
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 2,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),

                          decoration: BoxDecoration(
                            color: context.colors.darkGrey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: context.colors.ambar,
                              width: 1.5,
                            ),
                          ),

                          child: Text(
                            _event.categoria,
                            style: context.typography.labelMedium.copyWith(
                              color: context.colors.ambar,
                              fontSize: 16,
                              letterSpacing: 4,

                              //possivel sombra (teste)
                              shadows: [
                                Shadow(
                                  color: context.colors.brasa,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Container(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _event.titulo,
                            style: context.typography.displayLarge.copyWith(
                              color: Colors.white,
                              fontSize: 41,

                              //possivel sombra (teste)
                              shadows: [
                                Shadow(color: Colors.white, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          //===============================================================================
          const SizedBox(height: 3),

          //Infos basicas e botões de "Vou ir" e "Garantir ingresso"
          //===============================================================================
          StaggeredEntrance(
            index: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),

              child: Column(
                children: [
                  const SizedBox(height: 5),

                  //Caixa com infos basicas sobre o evento (trocar infos fixas por variaveis posteriormente)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),

                    decoration: BoxDecoration(
                      color: context.colors.navy,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DATA & HORA',
                                style: context.typography.labelSmall.copyWith(
                                  color: context.colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                DateFormat(
                                  "EEE dd MMM  HH:mm",
                                  "pt_BR",
                                ).format(_event.dataDoEvento),
                                style: context.typography.titleSmall.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Linha divisória
                        Container(
                          width: 1,
                          height: 40,
                          color: context.colors.border,
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LOCAL',
                                  style: context.typography.labelSmall.copyWith(
                                    color: context.colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _event.localizacao,
                                  style: context.typography.titleSmall.copyWith(
                                    color: context.colors.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //Espaçamento entre itens
                  const SizedBox(height: 16),

                  Column(
                    //Criar efeitp de confirmados e add o coração de curtida
                  ),

                  //Espaçamento entre itens
                  const SizedBox(height: 16),

                  //Botão de "VOU IR" (add função posteriormente)
                  TertiaryButton(
                    label: "VOU IR",
                    state: _event.isFavorite
                        ? ButtonState.success
                        : ButtonState.idle,
                    onPressed: _alternarPresenca,
                  ),

                  //Espaçamento entre itens
                  const SizedBox(height: 16),

                  //Botão de "GARANTIR INGRESSO" (add função posteriormente)
                  SecundaryButton(
                    label: "GARANTIR INGRESSO",
                    icon: Icons.local_activity,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          //===============================================================================
          const SizedBox(height: 20),

          //Line-up com artistas (Criar uma linha com os icones de perfil dos artistas envolvidos)
          //===============================================================================
          StaggeredEntrance(
            index: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Line-up",
                      style: context.typography.headlineMedium.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  //Lista de line-ups
                  const SizedBox(height: 10),
                  LineupIndicator(lineup: _event.lineUp),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sobre o Evento",
                      style: context.typography.headlineMedium.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Informações importantes",
                      style: context.typography.labelMedium.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //===============================================================================
          const SizedBox(height: 20),

          //Sobre o evento (Caixa de descrições ajustavel ao tamanho da descrição)
          //===============================================================================
          StaggeredEntrance(
            index: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _event.informacoes,
                textAlign: TextAlign.left,
                style: context.typography.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ),

          //===============================================================================
          const SizedBox(height: 30),

          //Localização e link pro maps
          //===============================================================================
          StaggeredEntrance(
            index: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Localização",
                      style: context.typography.headlineMedium.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  MapEvent(endereco: _event.localizacao),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _event.localizacao,
                      style: context.typography.bodyMedium.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //===============================================================================
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
