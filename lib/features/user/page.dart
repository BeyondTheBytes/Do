import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../config/routes.dart';
import '../../config/state.dart';
import '../../database/dataclass.dart';
import '../../database/services.dart';
import '../../presentation/button.dart';
import '../../presentation/event.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';
import '../utils/navigation.dart';
import 'picture.dart';
import 'sports.dart';

class UserPage extends StatelessWidget {
  final String uid;
  UserPage({required this.uid});

  final events = EventsService();
  final usersConfig = UserConfigService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserConfig>(
      stream: usersConfig.stream(uid),
      builder: (context, configSnapshot) {
        final userConfig = configSnapshot.data;
        return Scaffold(
          backgroundColor: AppColors.of(context).darkest,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(bottom: 25),
                  color: AppColors.of(context).medium,
                  child: _buildIntroInfo(userConfig),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 15)),
              if (userConfig != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: pageHorizontalPadding,
                    ),
                    child: SportTags(sports: userConfig.sports),
                  ),
                ),
              if (userConfig != null)
                SliverToBoxAdapter(
                  child: StreamBuilder<List<Event>>(
                    stream: events.asParticipant(uid),
                    builder: (context, snapshot) {
                      final events = snapshot.data;
                      if (events == null || events.isEmpty) return SizedBox();
                      return Padding(
                        padding: EdgeInsets.only(
                          top: 50,
                          left: pageHorizontalPadding,
                          right: pageHorizontalPadding,
                        ),
                        child: _buildEvents(context, events),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIntroInfo(UserConfig? userConfig) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NavigationButton(),
        DefaultHorizontalPadding(
          child: Row(
            children: [
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
                    );
                  },
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final name = AppState.auth.currentUser!.displayName!;
                    return AutoSizeText(
                      // ignore: prefer_interpolation_to_compose_strings
                      name.toLowerCase() + '.',
                      maxLines: 1,
                      style: AppTexts.of(context)
                          .title2
                          .copyWith(color: Colors.white),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        DefaultHorizontalPadding(
          child: Builder(
            builder: (context) {
              final description = userConfig?.description;
              if (description == null) return SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description.isNotEmpty
                          ? description
                          : """Conte-nos um pouco mais sobre você... """
                              """Você pode dizer que topa abrir uma breja depois """
                              """dos encontros ou como entrou nos esportes.""",
                      style: AppTexts.of(context).body1.copyWith(
                            color: description.isNotEmpty
                                ? Colors.white
                                : Colors.grey[300],
                            height: 1.4,
                          ),
                    ),
                    SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (context) => DialogWrapper(
                            child: _ChangeDescriptionDialog(
                          uid: AppState.auth.currentUser!.uid,
                          description: description,
                        )),
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
                ),
              );
            },
          ),
        ),
      ],
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
        SizedBox(height: 40),
        ...events.map((e) => EventHorizontalCard(event: e)),
      ],
    );
  }
}

class _ChangeDescriptionDialog extends StatefulWidget {
  final String uid;
  final String description;
  _ChangeDescriptionDialog({
    required this.uid,
    required this.description,
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

    AppRouter.of(context).popDialog();
  }
}
