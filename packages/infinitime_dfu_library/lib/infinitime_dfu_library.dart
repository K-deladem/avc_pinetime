// lib/infinitime_dfu_library.dart
library infinitime_dfu_library;

// Exports des modèles
export 'src/models/infinitime_uuids.dart';
export 'src/models/firmware_info.dart';
export 'src/models/firmware_validation_result.dart';
export 'src/models/dfu_files.dart';
export 'src/models/enums.dart';
export 'src/models/movement_data.dart';

// Exports des services
export 'src/services/infinitime_session.dart';
export 'src/services/dfu_service_manager.dart';
export 'src/services/firmware_manager.dart';

// Exports des utilitaires
export 'src/utils/infinitime_util.dart';
export 'src/utils/dfu_protocol_helper.dart';
export 'src/utils/data_parser.dart';


// Exports des exceptions
export 'src/exceptions/dfu_exceptions.dart';
