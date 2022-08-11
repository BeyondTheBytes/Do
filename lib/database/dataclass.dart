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
          placeDescription: event.placeDescription,
          point: event.point,
          sport: event.sport,
          photoUrl: event.photoUrl,
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
  final String placeDescription;
  final String photoUrl;
  final String observations;

  @JsonKey(name: DataclassesDocFields.eventCreatorUid)
  final String creatorUid;
  @JsonKey(name: DataclassesDocFields.eventParticipants)
  final Map<String, bool> participants;

  List<String> get getParticipants => participants.keys.toList();

  EventData({
    required this.sport,
    required this.date,
    required this.placeId,
    required this.placeDescription,
    required this.observations,
    required this.creatorUid,
    required this.photoUrl,
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

List<String> imagesSport(Sport sport) {
  switch (sport) {
    case Sport.soccer:
      return [
        'https://images.unsplash.com/photo-1551958219-acbc608c6377?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8c29jY2VyfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nnx8c29jY2VyfGVufDB8MHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OHx8c29jY2VyfGVufDB8MHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1600679472829-3044539ce8ed?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTF8fHNvY2NlcnxlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1553778263-73a83bab9b0c?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OXx8c29jY2VyfGVufDB8MHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1626248801379-51a0748a5f96?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTV8fHNvY2NlcnxlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
      ];
    case Sport.basketball:
      return [
        'https://images.unsplash.com/photo-1546519638-68e109498ffc?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8YmFza2V0YmFsbHxlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1519861531473-9200262188bf?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8YmFza2V0YmFsbHxlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1474224017046-182ece80b263?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NXx8YmFza2V0YmFsbHxlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1594623274890-6b45ce7cf44a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTV8fGJhc2tldGJhbGx8ZW58MHwwfDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1576437630698-61d25beb0038?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTh8fGJhc2tldGJhbGx8ZW58MHwwfDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1569731683228-5e7850ae0034?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTR8fGJhc2tldGJhbGx8ZW58MHwwfDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1543633550-f431af584afd?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mjl8fGJhc2tldGJhbGx8ZW58MHwwfDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
      ];
    case Sport.tennis:
      return [
        'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dGVubmlzfGVufDB8MHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1580153111806-5007b971dfe7?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fHRlbm5pc3xlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/flagged/photo-1576972405668-2d020a01cbfa?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nnx8dGVubmlzfGVufDB8MHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
      ];
    case Sport.volleyball:
      return [
        'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8dm9sbGV5YmFsbHxlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1547347298-4074fc3086f0?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dm9sbGV5YmFsbHxlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1619296094543-99aca1aa1f9e?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nnx8dm9sbGV5YmFsbHxlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1592656094267-764a45160876?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8dm9sbGV5YmFsbHxlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1601512986351-9b0e01780eef?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OHx8dm9sbGV5YmFsbHxlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1602161312299-5524518bc66e?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MjJ8fHZvbGxleWJhbGx8ZW58MHwwfDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
      ];
    case Sport.run:
      return [
        'https://images.unsplash.com/photo-1590333748338-d629e4564ad9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OHx8cnVufGVufDB8MHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1513593771513-7b58b6c4af38?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTF8fHJ1bnxlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1525026198548-4baa812f1183?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MjR8fHJ1bnxlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1449358070958-884ac9579399?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mzd8fHJ1bnxlbnwwfDB8MHx8&auto=format&fit=crop&w=900&q=60',
      ];
    case Sport.addrenalineSport:
      return [
        'https://images.unsplash.com/photo-1542727568-395b760e571d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8N3x8c2thdGV8ZW58MHwwfDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1542727934-07691d6ebf0e?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fHNrYXRlfGVufDB8MHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1500347425655-9d404d89abdd?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MzR8fHNrYXRlfGVufDB8MHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
        'https://images.unsplash.com/photo-1564485986486-06f447a399d8?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MjZ8fHNrYXRlfGVufDB8MHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
      ];
  }
}
