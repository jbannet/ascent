import 'package:json_annotation/json_annotation.dart';
import '../enums/goal.dart';
import '../enums/experience_level.dart';
import '../enums/block_type.dart';
import '../enums/progression_mode.dart';
import '../enums/session_tag.dart';
import '../enums/energy_system_tag.dart';
import '../enums/day_of_week.dart';
import '../enums/session_status.dart';
import '../enums/missed_session_policy.dart';
import '../enums/intensity_mode.dart';
import '../enums/rep_kind.dart';

class GoalConverter implements JsonConverter<Goal, String> {
  const GoalConverter();

  @override
  Goal fromJson(String json) => goalFromString(json);

  @override
  String toJson(Goal object) => goalToString(object);
}

class ExperienceLevelConverter implements JsonConverter<ExperienceLevel, String> {
  const ExperienceLevelConverter();

  @override
  ExperienceLevel fromJson(String json) => expFromString(json);

  @override
  String toJson(ExperienceLevel object) => expToString(object);
}

class BlockTypeConverter implements JsonConverter<BlockType, String> {
  const BlockTypeConverter();

  @override
  BlockType fromJson(String json) => blockTypeFromString(json);

  @override
  String toJson(BlockType object) => blockTypeToString(object);
}

class ProgressionModeConverter implements JsonConverter<ProgressionMode, String> {
  const ProgressionModeConverter();

  @override
  ProgressionMode fromJson(String json) => progressionFromString(json);

  @override
  String toJson(ProgressionMode object) => progressionToString(object);
}

class SessionTagConverter implements JsonConverter<SessionTag, String> {
  const SessionTagConverter();

  @override
  SessionTag fromJson(String json) => sessionTagFromString(json);

  @override
  String toJson(SessionTag object) => sessionTagToString(object);
}

class EnergySystemTagConverter implements JsonConverter<EnergySystemTag, String> {
  const EnergySystemTagConverter();

  @override
  EnergySystemTag fromJson(String json) => energySystemFromString(json);

  @override
  String toJson(EnergySystemTag object) => energySystemToString(object);
}

class DayOfWeekConverter implements JsonConverter<DayOfWeek, String> {
  const DayOfWeekConverter();

  @override
  DayOfWeek fromJson(String json) => dowFromString(json);

  @override
  String toJson(DayOfWeek object) => dowToString(object);
}

class SessionStatusConverter implements JsonConverter<SessionStatus, String> {
  const SessionStatusConverter();

  @override
  SessionStatus fromJson(String json) => statusFromString(json);

  @override
  String toJson(SessionStatus object) => statusToString(object);
}

class MissedSessionPolicyConverter implements JsonConverter<MissedSessionPolicy, String> {
  const MissedSessionPolicyConverter();

  @override
  MissedSessionPolicy fromJson(String json) => missedPolicyFromString(json);

  @override
  String toJson(MissedSessionPolicy object) => missedPolicyToString(object);
}

class IntensityModeConverter implements JsonConverter<IntensityMode, String> {
  const IntensityModeConverter();

  @override
  IntensityMode fromJson(String json) => intensityModeFromString(json);

  @override
  String toJson(IntensityMode object) => object.name;
}

class RepKindConverter implements JsonConverter<RepKind, String> {
  const RepKindConverter();

  @override
  RepKind fromJson(String json) => RepKind.values.firstWhere((e) => e.name == json);

  @override
  String toJson(RepKind object) => object.name;
}

class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String().split('T').first;
}

class SessionTagListConverter implements JsonConverter<List<SessionTag>, List<dynamic>> {
  const SessionTagListConverter();

  @override
  List<SessionTag> fromJson(List<dynamic> json) => 
      json.map((e) => sessionTagFromString(e.toString())).toList();

  @override
  List<dynamic> toJson(List<SessionTag> object) => 
      object.map(sessionTagToString).toList();
}