import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/features/scanner/domain/scan_local_repository.dart';
import 'package:reader/features/scanner/domain/scan_record.dart';

@injectable
class ScansViewModel extends ChangeNotifier {
  final ScanLocalRepository _repository;

  ScansViewModel(this._repository);

  List<ScanRecord> _scans = [];
  List<ScanRecord> get scans => _scans;

  Future<void> load() async {
    _scans = await _repository.getAll();
    notifyListeners();
  }
}