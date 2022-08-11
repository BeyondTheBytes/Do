import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../database/dataclass.dart';
import '../database/services.dart';
import 'button.dart';
import 'theme.dart';
import 'utils.dart';

class EventHorizontalCard extends StatelessWidget {
  final Event event;
  const EventHorizontalCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    return AspectRatio(
      aspectRatio: 1.75,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 3,
              spreadRadius: -2,
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(event.photoUrl),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.65),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: [0, 0.5, 0.6, 1],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButtons(context),
                  _buildInfo(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final relation =
        event.relation(context.watch<UserCredential?>()!.user!.uid);
    final iconData = () {
      switch (relation) {
        case EventRelation.none:
          return FontAwesomeIcons.arrowRightFromBracket;
        case EventRelation.participant:
        case EventRelation.creator:
          return FontAwesomeIcons.check;
      }
    };
    final backgroundcolor = () {
      switch (relation) {
        case EventRelation.none:
          return AppColors.of(context).medium;
        case EventRelation.participant:
        case EventRelation.creator:
          return AppColors.of(context).success;
      }
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Stack(
        //   children: [],
        // ),
        SizedBox(width: 5),
        GestureDetector(
          onTap: () => _updateStatus(context, relation),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundcolor(),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 1,
                  spreadRadius: -1,
                )
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 5),
                Text(
                  (event.getParticipants.length + 1).toString(),
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 9),
                  width: 0.5,
                  height: 18,
                  color: Colors.white,
                ),
                Icon(iconData(), size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static final _formatDoubleDigits = NumberFormat("00");
  Widget _buildInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 4, left: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle(
            style: AppTexts.of(context).title2.copyWith(color: Colors.white),
            child: Row(
              children: [
                Builder(builder: (context) {
                  if (DateTime.now().compareTo(event.date) > 0) {
                    return Text(
                      'Agora',
                      style: TextStyle(color: AppColors.of(context).warning),
                    );
                  }
                  final hour = _formatDoubleDigits.format(event.date.hour);
                  final minute = _formatDoubleDigits.format(event.date.minute);
                  return Text('${hour}h ${minute}min');
                }),
              ],
            ),
          ),
          SizedBox(height: 2),
          Builder(builder: (context) {
            final observations =
                event.observations.isEmpty ? '' : ' (${event.observations})';
            return Text(
              event.placeDescription + observations,
              maxLines: 1,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    EventRelation relation,
  ) async {
    final events = EventsService();

    if (relation == EventRelation.creator && event.getParticipants.isEmpty) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => _ConfirmationDialog(
          title: 'Quer deletar o encontro?',
          description: 'Não há pessoas confirmadas ainda...',
          positiveAnswer: 'Sim',
          negativeAnswer: 'Cancelar',
        ),
      );
      if (result == true) {
        await events.delete(event.id);
      }
      return;
    }

    switch (relation) {
      case EventRelation.creator:
      case EventRelation.participant:
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => _ConfirmationDialog(
            title: 'Deseja cancelar a inscrição?',
            description: 'Que pena, volte quando puder...',
            positiveAnswer: 'Sair',
            negativeAnswer: 'Não',
          ),
        );
        if (result == true) {
          await events.unparticipate(
            event.id,
            context.read<UserCredential?>()!.user!.uid,
          );
        }
        break;
      case EventRelation.none:
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => _ConfirmationDialog(
            title: 'Quer participar do encontro?',
            description: 'Não esqueça de verificar seu calendário :)',
            positiveAnswer: 'Sim',
            negativeAnswer: 'Cancelar',
          ),
        );
        if (result == true) {
          await events.participate(
            event.id,
            context.read<UserCredential?>()!.user!.uid,
          );
        }
    }
  }
}

class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final String description;
  final String positiveAnswer;
  final String negativeAnswer;
  const _ConfirmationDialog({
    required this.title,
    required this.description,
    required this.positiveAnswer,
    required this.negativeAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      child: CustomDialog(
        title: title,
        large: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              description,
              style:
                  AppTexts.of(context).body1.copyWith(color: Colors.grey[800]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: CustomButton(
                  child: Text(negativeAnswer),
                  style: AppButton.of(context).largeOutlined,
                  onPressed: () => AppRouter.of(context).popDialog(false),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: CustomButton(
                  child: Text(positiveAnswer),
                  style: AppButton.of(context).largeFilled,
                  onPressed: () => AppRouter.of(context).popDialog(true),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
