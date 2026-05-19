import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/aitmatov_theme.dart';

abstract class AitmatovRepository {
  Future<Either<Failure, List<AitmatovTheme>>> getAitmatovThemes();
}