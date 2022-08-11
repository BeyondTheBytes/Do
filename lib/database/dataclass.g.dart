// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dataclass.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventData _$EventDataFromJson(Map<String, dynamic> json) => EventData(
      sport: $enumDecode(_$SportEnumMap, json['sport']),
      date: convertToDate(json['date'] as Timestamp),
      placeId: json['placeId'] as String,
      placeDescription: json['placeDescription'] as String,
      observations: json['observations'] as String,
      creatorUid: json['creatorUid'] as String,
      photoUrl: json['photoUrl'] as String,
      point: convertToPoint(json['point'] as Map<String, Object?>),
      participants: (json['participants'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ),
    );

Map<String, dynamic> _$EventDataToJson(EventData instance) => <String, dynamic>{
      'date': convertFromDate(instance.date),
      'sport': _$SportEnumMap[instance.sport]!,
      'point': convertFromPoint(instance.point),
      'placeId': instance.placeId,
      'placeDescription': instance.placeDescription,
      'photoUrl': instance.photoUrl,
      'observations': instance.observations,
      'creatorUid': instance.creatorUid,
      'participants': instance.participants,
    };

const _$SportEnumMap = {
  Sport.soccer: 'soccer',
  Sport.basketball: 'basketball',
  Sport.tennis: 'tennis',
  Sport.volleyball: 'volleyball',
  Sport.run: 'run',
  Sport.addrenalineSport: 'addrenalineSport',
};

UserConfig _$UserConfigFromJson(Map<String, dynamic> json) => UserConfig(
      description: json['description'] as String?,
      sports: (json['sports'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SportEnumMap, e))
          .toList(),
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$UserConfigToJson(UserConfig instance) =>
    <String, dynamic>{
      'description': instance.description,
      'sports': instance.sports.map((e) => _$SportEnumMap[e]!).toList(),
      'phone': instance.phone,
    };
