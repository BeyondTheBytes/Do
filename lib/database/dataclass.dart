import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:json_annotation/json_annotation.dart';

import '../domain/parse.dart';

part 'dataclass.g.dart';

class DataclassesDocFields {
  static const String eventParticipants = 'participants';
  static const String eventCreatorUid = 'creatorUid';
  static const String eventSport = 'sport';
  static const String eventPoint = 'point';
  static const String userDescription = 'description';
  static const String userSports = 'sports';
}

enum EventRelation { participant, creator, none }

enum Sport {
  @JsonValue('soccer')
  soccer,
  @JsonValue('basketball')
  basketball,
  @JsonValue('tennis')
  tennis,
  @JsonValue('volleyball')
  volleyball,
  @JsonValue('run')
  run,
  @JsonValue('addrenalineSport')
  addrenalineSport,
}

String sportToStr(Sport sport) => _$SportEnumMap[sport]!;

class Event extends EventData {
  final String id;
  Event({
    required this.id,
    required EventData event,
  }) : super(
          creatorUid: event.creatorUid,
          date: event.date,
          observations: event.observations,
          participants: event.participants,
          placeId: event.placeId,
          point: event.point,
          sport: event.sport,
        );
}

@JsonSerializable()
class EventData {
  @JsonKey(fromJson: convertToDate, toJson: convertFromDate)
  final DateTime date;
  @JsonKey(name: DataclassesDocFields.eventSport)
  final Sport sport;

  @JsonKey(
    name: DataclassesDocFields.eventPoint,
    fromJson: convertToPoint,
    toJson: convertFromPoint,
  )
  final GeoFirePoint point;
  final String placeId;
  final String? observations;

  @JsonKey(name: DataclassesDocFields.eventCreatorUid)
  final String creatorUid;
  @JsonKey(name: DataclassesDocFields.eventParticipants)
  final Map<String, bool> participants;

  EventData({
    required this.sport,
    required this.date,
    required this.placeId,
    required this.observations,
    required this.creatorUid,
    required this.point,
    required Map<String, bool>? participants,
  }) : participants = participants ?? {};

  EventRelation relation(String uid) {
    if (uid == creatorUid) return EventRelation.creator;
    if (participants.containsKey(uid)) return EventRelation.participant;
    return EventRelation.none;
  }

  factory EventData.fromJson(Map<String, dynamic> json) =>
      _$EventDataFromJson(json);
  Map<String, dynamic> toJson() => _$EventDataToJson(this);
}

@JsonSerializable()
class UserConfig {
  @JsonKey(name: DataclassesDocFields.userDescription)
  final String description;
  @JsonKey(name: DataclassesDocFields.userSports)
  final List<Sport> sports;
  final String? phone;
  UserConfig({
    required String? description,
    required List<Sport>? sports,
    required this.phone,
  })  : description = description ?? '',
        sports = sports ?? [];
  UserConfig.empty()
      : sports = [],
        phone = null,
        description = '';

  factory UserConfig.fromJson(Map<String, dynamic>? json) =>
      (json == null) ? UserConfig.empty() : _$UserConfigFromJson(json);
  Map<String, dynamic> toJson() => _$UserConfigToJson(this);
}
