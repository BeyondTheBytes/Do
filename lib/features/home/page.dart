import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import '../../config/routes.dart';
import '../../config/state.dart';
import '../../database/dataclass.dart';
import '../../database/services.dart';
import '../../domain/structures.dart';
import '../../presentation/event.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';
import '../user/picture.dart';
import '../user/sports.dart';
import '../utils/location.dart';
import '../utils/navigation.dart';
import 'create_event.dart';

// TODO: let user edit radius
const _radius = 40.0;

class HomePage extends StatelessWidget {
  final userConfig = UserConfigService();
  final events = EventsService();

  @override
  Widget build(BuildContext context) {
    return LocationWrapper(
      builder: (context, locationResult) => _HomeWrapper(
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
                        radius: _radius,
                        from: DateTime.now(),
                      ),
                builder: (context, snapshot) => _buildPage(context, sports,
                    snapshot.data, locationResult?.failureOrNull),
              );
            }),
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
        SliverToBoxAdapter(child: NavigationButton()),
        SliverToBoxAdapter(
          child: DefaultHorizontalPadding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Do.',
                  style: AppTexts.of(context)
                      .title1
                      .copyWith(color: Colors.white, height: 1),
                ),
                Container(
                  width: 70,
                  height: 70,
                  child: StreamBuilder<User?>(
                    stream: AppState.auth.userStream,
                    builder: (context, snapshot) {
                      final user = snapshot.data;
                      return ProfilePicture(
                        canEdit: user?.photoURL == null,
                        url: user?.photoURL,
                        alternateNoPicture: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (sports != null) ...[
          SliverToBoxAdapter(
            child: DefaultHorizontalPadding(
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: SportTags(sports: sports),
              ),
            ),
          ),
          if (events != null) ...[
            SliverToBoxAdapter(child: SizedBox(height: 50)),
            ..._buildEvents(context, events),
          ],
        ],
        if (locationFailure != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: errorPadding,
              child: LocationPermissionCard(failure: locationFailure),
            ),
          ),
        if (events != null && events.isEmpty)
          SliverToBoxAdapter(
            child: DefaultHorizontalPadding(
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
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
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
        .map((e) =>
            SliverToBoxAdapter(child: DefaultHorizontalPadding(child: e)))
        .toList();
  }
}

// ////////////////////////////////////////////////////////////////
// WRAPPER
// ////////////////////////////////////////////////////////////////

class _HomeWrapper extends StatelessWidget {
  final Widget body;
  _HomeWrapper({required this.body});

  final entryController = EntryController();

  @override
  Widget build(BuildContext context) {
    return DismissibleKeyboardWrapper(
      child: Scaffold(
        backgroundColor: AppColors.of(context).darkest,
        body: body,
        floatingActionButton: FloatingActionButton(
          child: Icon(FontAwesomeIcons.plus, color: Colors.white),
          onPressed: () => showDialog<void>(
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
                    SuccessMessage.of(context)
                        .show('Evento Criado com Sucesso');
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
