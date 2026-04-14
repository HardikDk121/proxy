// lib/models/timetable_slot.g.dart
// ─────────────────────────────────────────────────────────────────────────────
// GENERATED CODE — mirrors what `flutter pub run build_runner build` produces.
// If you add/change @HiveField fields, re-run the generator and replace this
// file with the updated output (or update the field mappings manually).
// ─────────────────────────────────────────────────────────────────────────────

part of 'timetable_slot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimetableSlotAdapter extends TypeAdapter<TimetableSlot> {
  @override
  final int typeId = kTimetableSlotTypeId; // 1

  @override
  TimetableSlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimetableSlot(
      day:         fields[0] as int,
      subjectName: fields[1] as String,
      type:        fields[2] as String,
      time:        fields[3] as String,
      duration:    fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TimetableSlot obj) {
    writer
      ..writeByte(5) // field count
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.subjectName)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableSlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
