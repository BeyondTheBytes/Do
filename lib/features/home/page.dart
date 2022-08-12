import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

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
              return StreamBuilder<List<Event>>(
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
    List<Event>? events,
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
                      final user = snapshot.data!;
                      return ProfilePicture(
                        uid: user.uid,
                        url: user.photoURL,
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
          SliverToBoxAdapter(child: SizedBox(height: 60)),
          ...(events ?? [])
              .map((e) => SliverToBoxAdapter(
                    child: DefaultHorizontalPadding(
                        child: EventHorizontalCard(event: e)),
                  ))
              .withBetween(SliverToBoxAdapter(child: SizedBox(height: 30))),
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
                description: 'Não há eventos para esses filtros',
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
}

class _HomeWrapper extends StatefulWidget {
  final Widget body;
  const _HomeWrapper({required this.body});
  @override
  State<_HomeWrapper> createState() => _HomeWrapperState();
}

// ////////////////////////////////////////////////////////////////
// WRAPPER
// ////////////////////////////////////////////////////////////////

class _HomeWrapperState extends State<_HomeWrapper> {
  var _openned = false;

  final entryController = EntryController();

  @override
  Widget build(BuildContext context) {
    return DismissibleKeyboardWrapper(
      child: Scaffold(
        backgroundColor: AppColors.of(context).darkest,
        body: Stack(children: [
          widget.body,
          if (_openned)
            TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 200),
              tween: Tween<double>(begin: 0, end: _openned ? 1 : 0),
              builder: (context, value, child) =>
                  Opacity(opacity: value, child: child),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.5),
                padding: EdgeInsets.symmetric(horizontal: 30) +
                    EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom +
                          MediaQuery.of(context).padding.bottom +
                          70,
                    ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: CreateEventDialog(
                    entryController: entryController,
                    onAdd: () {
                      setState(() {
                        _openned = false;
                      });
                      SuccessMessage.of(context)
                          .show('Evento Criado com Sucesso');
                    },
                  ),
                ),
              ),
            ),
        ]),
        floatingActionButton: _FloatingActionButton(
          openned: _openned,
          onTap: (context) {
            if (_openned) entryController.remove();
            setState(() {
              _openned = !_openned;
            });
          },
        ),
      ),
    );
  }
}

class _FloatingActionButton extends StatelessWidget {
  final bool openned;
  final Function(BuildContext context) onTap;
  _FloatingActionButton({required this.onTap, required this.openned});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 150),
        tween: Tween<double>(begin: 0, end: openned ? 1 : 0),
        builder: (context, value, child) =>
            Transform.rotate(angle: value * pi * 0.25, child: child),
        child: Icon(FontAwesomeIcons.plus, color: Colors.white),
      ),
      onPressed: () => onTap(context),
    );
  }
}
