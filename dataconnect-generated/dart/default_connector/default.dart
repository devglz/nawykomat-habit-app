import 'package:firebase_core/firebase_core.dart';

class DefaultConnector {
  static final FirebaseApp app = Firebase.app();

  static ConnectorConfig connectorConfig = ConnectorConfig(
    region: 'us-central1',
    connectorName: 'default',
    projectId: 'nawykomat',
  );
}

class ConnectorConfig {
  final String region;
  final String connectorName;
  final String projectId;

  ConnectorConfig({
    required this.region,
    required this.connectorName,
    required this.projectId,
  });
}