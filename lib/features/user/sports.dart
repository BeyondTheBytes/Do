import 'package:flutter/material.dart';

import '../../database/dataclass.dart';
import '../../presentation/theme.dart';
import '../../domain/utils.dart';

class SportTags extends StatelessWidget {
  final List<Sport> sports;
  const SportTags({required this.sports});

  // TODO: add dialog

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 10,
      children: [
        ...sports.map((sport) => _buildTag(context, sport)).toList(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.of(context).medium, width: 2),
          ),
          child: Icon(Icons.add_rounded, color: AppColors.of(context).medium),
        ),
      ].withBetween(SizedBox(width: 8)),
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
