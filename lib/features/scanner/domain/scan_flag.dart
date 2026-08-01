enum ScanFlag {
  passedOk,
  unknownCard,
  invalidFormat,
  duplicateAttemptMesh,
  duplicateAttemptServer,
  rejected,
  unknown;

  String get serverValue => switch (this) {
    ScanFlag.passedOk => 'PASSED_OK',
    ScanFlag.unknownCard => 'UNKNOWN_CARD',
    ScanFlag.invalidFormat => 'INVALID_FORMAT',
    ScanFlag.duplicateAttemptMesh => 'DUPLICATE_ATTEMPT_MESH',
    ScanFlag.duplicateAttemptServer => 'DUPLICATE_ATTEMPT_SERVER',
    ScanFlag.rejected => 'REJECTED',
    ScanFlag.unknown => 'UNKNOWN',
  };
}
