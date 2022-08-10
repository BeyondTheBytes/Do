import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:json_annotation/json_annotation.dart';

import '../domain/parse.dart';

part 'dataclass.g.dart';

class DataclassesDocFields {
  static const String eventParticipants = 'participants';
  static const String eventCreatorUid = 'creatorUid';
  static const String eventSport = 'sport';
  static const String eventPoint = 'point';
  static const String eventDate = 'date';
  static const String eventDay = 'day';

  static const String userDescription = 'description';
  static const String userSports = 'sports';
  static const String userPhone = 'phone';
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

const defaultSports = [Sport.soccer, Sport.basketball, Sport.tennis];
String sportCode(Sport sport) => _$SportEnumMap[sport]!;
String sportStr(Sport sport) {
  switch (sport) {
    case Sport.soccer:
      return 'futebol';
    case Sport.basketball:
      return 'basquete';
    case Sport.tennis:
      return 'tênis';
    case Sport.volleyball:
      return 'vôlei';
    case Sport.run:
      return 'correr';
    case Sport.addrenalineSport:
      return 'adrenalina';
  }
}

IconData sportIcon(Sport sport) {
  switch (sport) {
    case Sport.soccer:
      return FontAwesomeIcons.futbol;
    case Sport.basketball:
      return FontAwesomeIcons.basketball;
    case Sport.tennis:
      return FontAwesomeIcons.baseball;
    case Sport.volleyball:
      return FontAwesomeIcons.volleyball;
    case Sport.run:
      return FontAwesomeIcons.shoePrints;
    case Sport.addrenalineSport:
      return Icons.skateboarding_rounded;
  }
}

String formatDate(DateTime date) => '${date.year}/${date.month}/${date.day}';

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
  @JsonKey(
    name: DataclassesDocFields.eventDate,
    fromJson: convertToDate,
    toJson: convertFromDate,
  )
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
  Map<String, dynamic> toJson() => <String, Object?>{
        ..._$EventDataToJson(this),
        DataclassesDocFields.eventDay: formatDate(date),
      };
}

@JsonSerializable()
class UserConfig {
  @JsonKey(name: DataclassesDocFields.userDescription)
  final String description;
  @JsonKey(name: DataclassesDocFields.userSports)
  final List<Sport> sports;
  @JsonKey(name: DataclassesDocFields.userPhone)
  final String? phone;
  UserConfig({
    required String? description,
    required List<Sport>? sports,
    required this.phone,
  })  : description = description ?? '',
        sports = sports ?? defaultSports;
  UserConfig.empty()
      : sports = defaultSports,
        phone = null,
        description = '';

  factory UserConfig.fromJson(Map<String, dynamic>? json) =>
      (json == null) ? UserConfig.empty() : _$UserConfigFromJson(json);
  Map<String, dynamic> toJson() => _$UserConfigToJson(this);
}
