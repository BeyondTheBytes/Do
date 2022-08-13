import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../config/routes.dart';
import '../../config/state.dart';
import '../../database/dataclass.dart';
import '../../database/services.dart';
import '../../presentation/button.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';

class SportTags extends StatelessWidget {
  final List<Sport> sports;
  const SportTags({required this.sports});

  // TODO: add dialog

  @override
  Widget build(BuildContext context) {
    return EntirelyTappable(
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => DialogWrapper(
          child: ConfigSportsDialog(
            interests: sports,
            onSaved: AppRouter.of(context).popDialog,
          ),
        ),
      ),
      child: Wrap(
        runSpacing: 10,
        spacing: 10,
        children: [
          ...sports.map((sport) => _buildTag(context, sport)).toList(),
          Container(
            decoration: BoxDecoration(
              color: AppColors.of(context).medium,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(2),
            child: Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, Sport sport) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).medium,
        borderRadius: BorderRadius.circular(200),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Text(
        sportStr(sport),
        style: AppTexts.of(context).body1.copyWith(color: Colors.white),
      ),
    );
  }
}

class ConfigSportsDialog extends StatefulWidget {
  final List<Sport> interests;
  final Function() onSaved;
  const ConfigSportsDialog({
    required this.interests,
    required this.onSaved,
  });
  @override
  State<ConfigSportsDialog> createState() => _ConfigSportsDialogState();
}

class _ConfigSportsDialogState extends State<ConfigSportsDialog> {
  late var _interests = widget.interests;

  static const _iconsPadding = 15.0;
  static const _crossAxisCount = 2;
  static const _buttonAspectRatio = 1.0;

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Interesses',
      child: Column(
        children: [
          _createSportsGrid(),
          SizedBox(height: 30),
          CustomButton(
            child: Text('Salvar'),
            onPressed: () => _saveInterests(context),
            style: AppButton.of(context).largeFilled,
          ),
        ],
      ),
    );
  }

  Widget _createSportsGrid() {
    final buttons = Sport.values
        .map((sport) => _buildIconButton(
              context,
              sport,
              selected: _interests.contains(sport),
            ))
        .toList();

    final columns = <Widget>[];
    for (var i = 0; i < buttons.length; i += _crossAxisCount) {
      columns.add(_createRow(buttons.sublist(i, i + _crossAxisCount)));
    }
    return Column(
      children: columns
          .withBetween(
            SizedBox(height: _iconsPadding),
          )
          .toList(),
    );
  }

  Widget _createRow(List<Widget> widgets) {
    return Row(
      children: widgets
          .map((widget) => Expanded(child: widget))
          .cast<Widget>()
          .withBetween(SizedBox(width: _iconsPadding))
          .toList(),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    Sport sport, {
    required bool selected,
  }) {
    final name = sportStr(sport);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: selected ? 1 : 0),
      duration: Duration(milliseconds: 50),
      builder: (context, perc, _) {
        final foregroundColor = ColorTween(
          begin: AppColors.of(context).dark,
          end: Colors.white,
        ).lerp(perc);
        return GestureDetector(
          onTap: () {
            if (selected) {
              setState(() {
                _interests = _interests.where((s) => s != sport).toList();
              });
            } else {
              setState(() {
                _interests = [..._interests, sport];
              });
            }
          },
          child: AspectRatio(
            aspectRatio: _buttonAspectRatio,
            child: Container(
              decoration: BoxDecoration(
                color: ColorTween(
                  begin: Colors.white,
                  end: AppColors.of(context).medium,
                ).lerp(perc),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    spreadRadius: -1.5,
                  ),
                ],
              ),
              padding: EdgeInsets.all(22),
              child: Column(
                children: [
                  Expanded(
                    child: Icon(
                      sportIcon(sport),
                      color: foregroundColor,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 10),
                  AutoSizeText(
                    name.substring(0, 1).toUpperCase() + name.substring(1),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: AppTexts.of(context)
                        .body1
                        .copyWith(color: foregroundColor),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveInterests(BuildContext context) async {
    final users = UserConfigService();
    await users.setInterests(
      AppState.auth.currentUser!.uid,
      interests: _interests,
    );
    widget.onSaved();
  }
}
