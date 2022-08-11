import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:provider/provider.dart';

import '../../database/dataclass.dart';
import '../../database/services.dart';
import '../../domain/structures.dart';
import '../../presentation/event.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';
import '../user/sports.dart';
import '../utils/location.dart';
import 'create_event.dart';

// TODO: add editable
const _radius = 40.0;

class HomePage extends StatelessWidget {
  final userConfig = UserConfigService();
  final events = EventsService();

  @override
  Widget build(BuildContext context) {
    return _HomeWrapper(
      body: StreamBuilder<UserConfig>(
          stream:
              userConfig.stream(context.watch<UserCredential?>()!.user!.uid),
          builder: (context, snapshot) {
            final userConfig = snapshot.data;
            final sports = userConfig?.sports;

            final locationResult = context.watch<LocationResult>();
            final location = locationResult.successOrNull;

            return StreamBuilder<List<Event>>(
              stream: (sports == null || location == null)
                  ? null
                  : events.nearby(
                      sports,
                      GeoFirePoint(location.latitude, location.longitude),
                      radius: _radius,
                      from: DateTime.now(),
                    ),
              builder: (context, snapshot) => _buildPage(
                  context, sports, snapshot.data, locationResult.failureOrNull),
            );
          }),
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
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.top + 35),
        ),
        SliverToBoxAdapter(
          child: _padding(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${_radius.round()}km, hoje  ',
                          style: AppTexts.of(context).kicker.copyWith(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                        ),
                        // TODO: add editable
                        // Icon(FontAwesomeIcons.penToSquare, size: 15),
                      ],
                    ),
                    Text(
                      'Do.',
                      style: AppTexts.of(context)
                          .title1
                          .copyWith(color: Colors.white, height: 1),
                    ),
                  ],
                ),
                Container(
                  width: 70,
                  height: 70,
                  child: ProfilePicture(
                    url: context.watch<UserCredential?>()!.user!.photoURL,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (sports != null) ...[
          SliverToBoxAdapter(
            child: _padding(Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: SportTags(sports: sports),
            )),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 60)),
          ...(events ?? [])
              .map((e) => SliverToBoxAdapter(
                    child: _padding(EventHorizontalCard(event: e)),
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
            child: _padding(Padding(
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

  Widget _padding(Widget child) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: 30), child: child);
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
                        bottom: MediaQuery.of(context).padding.bottom + 100),
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
