// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_slot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimetableSlotAdapter extends TypeAdapter<TimetableSlot> {
  @override
  final int typeId = 1;

  @override
  TimetableSlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimetableSlot(
      day: fields[0] as int,
      subjectName: fields[1] as String,
      type: fields[2] as String,
      time: fields[3] as String,
      duration: fields[4] as String,
      lastLoggedDate: fields[5] as DateTime?,
      lastLoggedStatus: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TimetableSlot obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.subjectName)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.lastLoggedDate)
      ..writeByte(6)
      ..write(obj.lastLoggedStatus);
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
