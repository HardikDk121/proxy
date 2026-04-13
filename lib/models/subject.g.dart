// lib/models/subject.g.dart
// ─────────────────────────────────────────────────────────────────────────────
// GENERATED CODE — DO NOT EDIT BY HAND.
// Equivalent to what `flutter pub run build_runner build` produces.
// If you add/change @HiveField fields, re-run the generator and replace
// this file with the updated output.
// ─────────────────────────────────────────────────────────────────────────────

part of 'subject.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = kSubjectTypeId; // 0

  @override
  Subject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subject(
      name: fields[0] as String,
      type: fields[1] as String,
      attended: fields[2] as int,
      total: fields[3] as int,
      durationHours: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer
      ..writeByte(5) // field count
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.attended)
      ..writeByte(3)
      ..write(obj.total)
      ..writeByte(4)
      ..write(obj.durationHours);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
