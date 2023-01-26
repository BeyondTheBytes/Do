import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../config/routes.dart';
import '../../config/state.dart';
import '../../database/dataclass.dart';
import '../../database/services.dart';
import '../../presentation/button.dart';
import '../../presentation/event.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';
import '../auth/utils.dart';
import '../utils/navigation.dart';
import 'picture.dart';
import 'sports.dart';

final _topColor = (BuildContext context) => AppColors.of(context).medium;
final _bottomColor = (BuildContext context) => AppColors.of(context).darkest;

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final events = EventsService();
  final usersConfig = UserConfigService();

  @override
  Widget build(BuildContext context) {
    final uid = AppState.auth.currentUser!.uid;
    return StreamBuilder<UserConfig>(
      stream: usersConfig.stream(uid),
      builder: (context, configSnapshot) {
        final userConfig = configSnapshot.data;
        final description = userConfig?.description;
        return Scaffold(
          body: BackgroundColorsWrapper(
            topColor: _topColor(context),
            bottomColor: _bottomColor(context),
            child: CustomScrollView(
              slivers: [
                UserProvider(
                  builder: (context, user) {
                    final username = '${user.displayName!.toLowerCase()}.';
                    return SliverPersistentHeader(
                      pinned: true,
                      floating: false,
                      delegate: _SliverAppBar(
                        uid: uid,
                        photoUrl: user.photoURL,
                        username: username,
                        maxExtent: getAppBarMinHeight(context) + 120,
                        minExtent: getAppBarMinHeight(context),
                      ),
                    );
                  },
                ),
                if (description != null)
                  SliverToBoxAdapter(
                    child: Container(
                      color: _topColor(context),
                      padding: EdgeInsets.only(bottom: 20),
                      child: _buildIntroInfo(context, description),
                    ),
                  ),
                SliverFillRemaining(
                  fillOverscroll: false,
                  hasScrollBody: false,
                  child: Container(
                    color: _bottomColor(context),
                    padding: EdgeInsets.only(top: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (userConfig != null)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: pageHorizontalPadding,
                            ),
                            child: SportTags(sports: userConfig.sports),
                          ),
                        if (userConfig != null)
                          StreamBuilder<List<Event>>(
                            stream: events.asParticipant(uid),
                            builder: (context, snapshot) {
                              final events = snapshot.data;
                              if (events == null || events.isEmpty) {
                                return SizedBox();
                              }
                              return Padding(
                                padding: EdgeInsets.only(
                                  top: 50,
                                  left: pageHorizontalPadding,
                                  right: pageHorizontalPadding,
                                  bottom:
                                      MediaQuery.of(context).padding.bottom +
                                          10,
                                ),
                                child: _buildEvents(context, events),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIntroInfo(BuildContext context, String description) {
    return DefaultHorizontalPadding(
      child: Builder(
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description.isNotEmpty
                    ? description
                    : """Fale um pouco sobre você... """,
                style: AppTexts.of(context).body1.copyWith(
                      color: description.isNotEmpty
                          ? Colors.white
                          : Colors.grey[300],
                      height: 1.4,
                    ),
              ),
              SizedBox(height: 4),
              EntirelyTappable(
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (context) => DialogWrapper(
                    child: _ChangeDescriptionDialog(
                      uid: AppState.auth.currentUser!.uid,
                      description: description,
                      onChange: () => setState(() {}),
                    ),
                  ),
                ),
                child: Text(
                  description.isNotEmpty ? 'editar' : 'adicionar',
                  style: AppTexts.of(context).body1.copyWith(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEvents(BuildContext context, List<Event> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eventos',
          style: AppTexts.of(context).title2.copyWith(color: Colors.white),
        ),
        SizedBox(height: 13),
        ...events
            .map((e) => EventHorizontalCard(
                  event: e,
                  showCompleteDate: true,
                ))
            .withBetween<Widget>(SizedBox(height: 20)),
      ],
    );
  }
}

// INTRO SLIVER

class _SliverAppBar extends SliverPersistentHeaderDelegate {
  final String uid;
  final String username;
  final String? photoUrl;

  final double minExtent;
  final double maxExtent;

  _SliverAppBar({
    required this.uid,
    required this.username,
    required this.photoUrl,
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

    final infoLeft = percClosed * NavigationButton.size;
    final infoTop = lerpDouble(
      NavigationButton.paddingAbove +
          NavigationButton.size +
          NavigationButton.paddingBelow,
      10,
      percClosed,
    )!;
    final logoSize = 70.0 - percClosed * 30;

    return Container(
      color: _topColor(context),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        children: [
          Positioned(
            top: buttonTop,
            child: NavigationButton.withoutPadding(),
          ),
          Positioned(
            left: infoLeft,
            top: infoTop,
            child: Container(
              width: MediaQuery.of(context).size.width - infoLeft,
              child: DefaultHorizontalPadding(
                child: Row(
                  children: [
                    Container(
                      width: logoSize,
                      height: logoSize,
                      child: ProfilePicture(
                        url: photoUrl,
                        canEdit: percClosed == 0,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: AutoSizeText(
                        username,
                        maxLines: 1,
                        style: AppTexts.of(context)
                            .title2
                            .copyWith(color: Colors.white),
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
    if (maxExtent != oldDelegate.maxExtent) return true;
    if (minExtent != oldDelegate.minExtent) return true;
    if (uid != oldDelegate.uid) return true;
    if (username != oldDelegate.username) return true;
    if (photoUrl != oldDelegate.photoUrl) return true;
    return false;
  }
}

// DIALOG

class _ChangeDescriptionDialog extends StatefulWidget {
  final String uid;
  final String description;
  final Function() onChange;
  _ChangeDescriptionDialog({
    required this.uid,
    required this.description,
    required this.onChange,
  });

  @override
  State<_ChangeDescriptionDialog> createState() =>
      _ChangeDescriptionDialogState();
}

class _ChangeDescriptionDialogState extends State<_ChangeDescriptionDialog> {
  late final controller = TextEditingController(text: widget.description);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Descrição de Perfil',
      child: Column(children: [
        TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
        ),
        SizedBox(height: 15),
        CustomButton(
          child: Text('Salvar'),
          style: AppButton.of(context).largeFilled,
          onPressed: () => _onTap(context),
        ),
      ]),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    final userConfig = UserConfigService();
    await userConfig.setDescription(widget.uid, description: controller.text);

    widget.onChange();
    AppRouter.of(context).popDialog();
  }
}
