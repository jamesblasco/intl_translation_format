
import 'package:intl_translation/generate_localized.dart';

class GenerationConfig {
  bool useJson;
  bool useDeferredLoading;
  String codegenMode;

  GenerationConfig({
    this.useJson,
    this.useDeferredLoading,
    this.codegenMode,
  });

  MessageGeneration getMessageGeneration()  {
    final generation =
        (useJson ?? false) ? new JsonMessageGeneration() : new MessageGeneration();
    generation.useDeferredLoading = useDeferredLoading ?? true;
    generation.codegenMode = codegenMode ?? '';
    return generation;
  }
}
