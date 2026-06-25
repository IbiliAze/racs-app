enum ScanFlag {
  passedOk,
  unknownTicket,
  invalidFormat,
  duplicateAttemptMesh,
  duplicateAttemptServer,
  rejected,
  unknown;

  String get serverValue => switch (this) {
    ScanFlag.passedOk => 'PASSED_OK',
    ScanFlag.unknownTicket => 'UNKNOWN_TICKET',
    ScanFlag.invalidFormat => 'INVALID_FORMAT',
    ScanFlag.duplicateAttemptMesh => 'DUPLICATE_ATTEMPT_MESH',
    ScanFlag.duplicateAttemptServer => 'DUPLICATE_ATTEMPT_SERVER',
    ScanFlag.rejected => 'REJECTED',
    ScanFlag.unknown => 'UNKNOWN',
  };
}
