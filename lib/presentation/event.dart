import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../config/routes.dart';
import '../config/state.dart';
import '../database/dataclass.dart';
import '../database/services.dart';
import 'button.dart';
import 'theme.dart';
import 'utils.dart';

class EventHorizontalCard extends StatelessWidget {
  final Event event;
  final bool showCompleteDate;
  const EventHorizontalCard({
    required this.event,
    required this.showCompleteDate,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    return AspectRatio(
      aspectRatio: 1.4,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 3,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[400],
                image: DecorationImage(
                  image: NetworkImage(event.photoUrl),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            _buildInfo(context),
          ],
        ),
      ),
    );
  }

  static final _formatDoubleDigits = NumberFormat("00");
  static final _dateFormat = DateFormat('dd/MM/yy');
  Widget _buildInfo(BuildContext context) {
    final amountParticipants = event.getParticipants.length;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            color: ColorTween(
                    begin: Colors.white, end: AppColors.of(context).medium)
                .lerp(0.1)!
                .withOpacity(0.85),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    DefaultTextStyle(
                      style: AppTexts.of(context)
                          .body1
                          .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      child: Builder(builder: (context) {
                        final hour =
                            _formatDoubleDigits.format(event.date.hour);
                        final minute =
                            _formatDoubleDigits.format(event.date.minute);

                        if (showCompleteDate) {
                          return Text(
                            """${_dateFormat.format(event.date)} - ${hour}h ${minute}min""",
                          );
                        }

                        if (DateTime.now().compareTo(event.date) < 0) {
                          return Text('${hour}h ${minute}min');
                        }

                        return Text(
                          'Agora',
                          style:
                              TextStyle(color: AppColors.of(context).success),
                        );
                      }),
                    ),
                    if (!showCompleteDate)
                      Text(
                        """ ($amountParticipants confirmado${amountParticipants == 1 ? '' : 's'})""",
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  event.placeDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
                if (event.observations.isNotEmpty)
                  Text(
                    '(${event.observations})',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          height: event.observations.isNotEmpty ? 80 : 63,
          child: _buildButton(context),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    final canChange = DateTime.now().compareTo(event.date) < 0;

    final isParticipant = event.isParticipant(AppState.auth.currentUser!.uid);
    final iconData =
        isParticipant ? FontAwesomeIcons.check : FontAwesomeIcons.arrowRight;
    final backgroundcolor = isParticipant
        ? AppColors.of(context).success
        : AppColors.of(context).medium;

    return GestureDetector(
      onTap: !canChange ? () {} : () => _updateStatus(context),
      child: Container(
        width: 60,
        height: 80,
        decoration: BoxDecoration(
          color: backgroundcolor,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 1,
              spreadRadius: -1,
            )
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Icon(iconData, size: 16),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context) async {
    final isParticipant = event.isParticipant(AppState.auth.currentUser!.uid);

    final events = EventsService();
    if (isParticipant) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => _ConfirmationDialog(
          title: 'Deseja cancelar a inscrição?',
          description: 'Que pena, volte quando puder...',
          positiveAnswer: 'Sair',
          negativeAnswer: 'Não',
        ),
      );
      if (result != true) return;

      if (isParticipant && event.getParticipants.length == 1) {
        await events.delete(event.id);
      } else {
        await events.unparticipate(
          event.id,
          AppState.auth.currentUser!.uid,
        );
      }
    } else {
      HapticFeedback.heavyImpact();
      await events.participate(
        event.id,
        AppState.auth.currentUser!.uid,
      );
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
