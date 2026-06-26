class SyncResult {
  final int pushed;
  final int pulled;
  final String? error;
  const SyncResult({this.pushed = 0, this.pulled = 0, this.error});
  bool get success => error == null;
}

class BleService {
  Stream<Map<String, String>> get peersStream => const Stream.empty();

  Future<bool> requestPermissions() async => false;
  Future<void> startDiscovery() async {}
  Future<void> stopDiscovery() async {}

  Future<SyncResult> syncWithPeer(String deviceId) async {
    return const SyncResult(pushed: 0, pulled: 0);
  }

  void dispose() {}
}
