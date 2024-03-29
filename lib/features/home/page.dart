import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../config/state.dart';
import '../../database/dataclass.dart';
import '../../database/services.dart';
import '../../domain/structures.dart';
import '../../presentation/event.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';
import '../auth/utils.dart';
import '../user/picture.dart';
import '../user/sports.dart';
import '../utils/location.dart';
import '../utils/navigation.dart';
import 'create_event.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final userConfig = UserConfigService();
  final events = EventsService();

  Color _backgroundColor(BuildContext context) => AppColors.of(context).darkest;
  Widget _sliverWrapper(BuildContext context, Widget child) =>
      SliverToBoxAdapter(
        child: Container(color: _backgroundColor(context), child: child),
      );

  @override
  Widget build(BuildContext context) {
    return LocationWrapper(
      builder: (context, locationResult) => Scaffold(
        backgroundColor: _backgroundColor(context),
        body: StreamBuilder<UserConfig>(
            stream: userConfig.stream(AppState.auth.currentUser!.uid),
            builder: (context, snapshot) {
              final userConfig = snapshot.data;
              final sports = userConfig?.sports;
              final location = locationResult?.successOrNull;
              return StreamBuilder<EventDays>(
                stream: (sports == null || location == null)
                    ? null
                    : events.nearby(
                        sports,
                        GeoFirePoint(location.latitude, location.longitude),
                        radius: Constants.kmRadius.toDouble(),
                        from: DateTime.now(),
                      ),
                builder: (context, snapshot) => _buildPage(context, sports,
                    snapshot.data, locationResult?.failureOrNull),
              );
            }),
        floatingActionButton: FloatingActionButton(
          child: Icon(FontAwesomeIcons.plus, color: Colors.white),
          onPressed: () => _createEvent(context),
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    List<Sport>? sports,
    EventDays? events,
    Failure? locationFailure,
  ) {
    const errorPadding = EdgeInsets.only(top: 60);
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          floating: false,
          delegate: _SliverAppBar(
            maxExtent: getAppBarMinHeight(context) + 100,
            minExtent: getAppBarMinHeight(context),
          ),
        ),
        if (sports != null) ...[
          _sliverWrapper(
            context,
            DefaultHorizontalPadding(
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: SportTags(sports: sports),
              ),
            ),
          ),
          if (events != null) ...[
            _sliverWrapper(context, SizedBox(height: 50)),
            ..._buildEvents(context, events),
          ],
        ],
        if (locationFailure != null)
          _sliverWrapper(
            context,
            Padding(
              padding: errorPadding,
              child: LocationPermissionCard(
                failure: locationFailure,
                onAccept: () => setState(() {}),
              ),
            ),
          ),
        if (events != null && events.isEmpty)
          _sliverWrapper(
            context,
            DefaultHorizontalPadding(
                child: Padding(
              padding: errorPadding,
              child: IconErrorWidget(
                icon: Icon(
                  FontAwesomeIcons.boxArchive,
                  color: Colors.white,
                  size: IconErrorWidget.iconSize,
                ),
                title: 'Sem eventos...',
                description:
                    """Não há eventos na sua região. Crie um evento e chame seus amigos.""",
              ),
            )),
          ),
        if (events != null && events.isNotEmpty)
          _sliverWrapper(
            context,
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ),
      ],
    );
  }

  List<Widget> _buildEvents(BuildContext context, EventDays events) {
    final buildDayEvents = (String title, List<Event> events) => <Widget>[
          Text(
            title,
            style: AppTexts.of(context).title3.copyWith(color: Colors.white),
          ),
          SizedBox(height: 10),
          ...(events)
              .map((e) => EventHorizontalCard(
                    event: e,
                    showCompleteDate: false,
                  ))
              .withBetween(SizedBox(height: 15)),
        ];

    return [
      if (events.today.isNotEmpty) ...buildDayEvents('Hoje', events.today),
      if (events.today.isNotEmpty && events.today.isNotEmpty)
        SizedBox(height: 60),
      if (events.tomorrow.isNotEmpty)
        ...buildDayEvents('Amanhã', events.tomorrow),
    ]
        .map((e) => _sliverWrapper(context, DefaultHorizontalPadding(child: e)))
        .toList();
  }

  final entryController = EntryController();

  void _createEvent(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          entryController.remove();
          return true;
        },
        child: DialogWrapper(
          child: CreateEventDialog(
            entryController: entryController,
            onAdd: () {
              AppRouter.of(context).popDialog();
              SuccessMessage.of(context).show('Evento Criado com Sucesso');
            },
          ),
        ),
      ),
    );
  }
}

class _SliverAppBar extends SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  _SliverAppBar({
    required this.minExtent,
    required this.maxExtent,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final percClosed = min(shrinkOffset / (maxExtent - minExtent), 1.0);

    final buttonTop = NavigationButton.paddingAbove - percClosed * 10;

    final titleLeft = percClosed * NavigationButton.size;
    final titleTop = lerpDouble(
      NavigationButton.paddingAbove +
          NavigationButton.size +
          NavigationButton.paddingBelow,
      10,
      percClosed,
    )!;
    final titleSize = AppTexts.of(context).title1.fontSize! - percClosed * 20.0;
    final logoOpacity = max(0.0, 1.0 - percClosed * 5);

    return Container(
      color: ColorTween(
        begin: AppColors.of(context).darkest,
        end: Colors.black,
      ).lerp(percClosed / 2),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        children: [
          Positioned(
            top: buttonTop,
            child: NavigationButton.withoutPadding(),
          ),
          Positioned(
            left: titleLeft,
            top: titleTop,
            child: Container(
              width: MediaQuery.of(context).size.width - titleLeft,
              child: DefaultHorizontalPadding(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Do.',
                      style: AppTexts.of(context).title1.copyWith(
                            fontSize: titleSize,
                            color: Colors.white,
                            height: 1,
                          ),
                    ),
                    if (logoOpacity != 0)
                      Opacity(
                        opacity: logoOpacity,
                        child: Container(
                          width: 70,
                          height: 70,
                          child: UserProvider(
                            builder: (context, user) => ProfilePicture(
                              canEdit: user.photoURL == null,
                              url: user.photoURL,
                              alternateNoPicture: true,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBar oldDelegate) {
    // TODO: improve performance
    return false;
  }
}
