/// 種目マスターデータ
/// 種目名から部位を逆引きするための共通データ
class ExerciseMasterData {
  // 🔧 v1.0.243: 部位別種目マップ（add_workout_screen.dartから抽出）
  static const Map<String, List<String>> muscleGroupExercises = {
    AppLocalizations.of(context)!.bodyPartChest: [AppLocalizations.of(context)!.exerciseBenchPress, AppLocalizations.of(context)!.exerciseDumbbellPress, AppLocalizations.of(context)!.exerciseInclinePress, AppLocalizations.of(context)!.exercise_11c97451, AppLocalizations.of(context)!.workout_e85fb0a4, AppLocalizations.of(context)!.workout_b18d1691, AppLocalizations.of(context)!.workout_c196525e, AppLocalizations.of(context)!.exerciseCableFly, AppLocalizations.of(context)!.exerciseDips, AppLocalizations.of(context)!.exercise_fbe3be86, AppLocalizations.of(context)!.workout_aaa776e7],
    AppLocalizations.of(context)!.bodyPartLegs: [AppLocalizations.of(context)!.exercise_8c982e86, AppLocalizations.of(context)!.exercise_4e99d714, AppLocalizations.of(context)!.exercise_1602d233, AppLocalizations.of(context)!.exerciseSquat, AppLocalizations.of(context)!.exerciseLegPress, AppLocalizations.of(context)!.exerciseLegExtension, AppLocalizations.of(context)!.exerciseLegCurl, AppLocalizations.of(context)!.exercise_0afc8ed2, AppLocalizations.of(context)!.workout_a19f4e60, AppLocalizations.of(context)!.workout_4027c245, AppLocalizations.of(context)!.workout_dc27b01c, AppLocalizations.of(context)!.exerciseCalfRaise, AppLocalizations.of(context)!.workout_7cb5b362],
    AppLocalizations.of(context)!.bodyPartBack: [AppLocalizations.of(context)!.exerciseDeadlift, AppLocalizations.of(context)!.exerciseLatPulldown, AppLocalizations.of(context)!.workout_be7c87e2, AppLocalizations.of(context)!.workout_8d5f0039, AppLocalizations.of(context)!.exerciseChinUp, AppLocalizations.of(context)!.exercisePullUp, AppLocalizations.of(context)!.exerciseBentOverRow, AppLocalizations.of(context)!.workout_f67592f1, AppLocalizations.of(context)!.workout_78f50d3b, AppLocalizations.of(context)!.exerciseSeatedRow, AppLocalizations.of(context)!.workout_f8d1b968, AppLocalizations.of(context)!.workout_56b5390a, AppLocalizations.of(context)!.workout_600bfaf4],
    AppLocalizations.of(context)!.bodyPartShoulders: [AppLocalizations.of(context)!.exerciseShoulderPress, AppLocalizations.of(context)!.exercise_b9e82d29, AppLocalizations.of(context)!.exercise_158c0c0a, AppLocalizations.of(context)!.exerciseSideRaise, AppLocalizations.of(context)!.workout_0d3898b0, AppLocalizations.of(context)!.exerciseFrontRaise, AppLocalizations.of(context)!.workout_61db805d, AppLocalizations.of(context)!.exerciseRearDeltFly, AppLocalizations.of(context)!.workout_a2742c19, AppLocalizations.of(context)!.exerciseUprightRow, AppLocalizations.of(context)!.workout_6a40751e],
    AppLocalizations.of(context)!.bodyPartBiceps: [AppLocalizations.of(context)!.exerciseBarbellCurl, AppLocalizations.of(context)!.workout_6bc85042, AppLocalizations.of(context)!.exerciseDumbbellCurl, AppLocalizations.of(context)!.workout_143ec9bf, AppLocalizations.of(context)!.exerciseHammerCurl, AppLocalizations.of(context)!.exercisePreacherCurl, AppLocalizations.of(context)!.workout_9556156f, AppLocalizations.of(context)!.workout_6a8e2907, AppLocalizations.of(context)!.exerciseCableCurl, AppLocalizations.of(context)!.workout_6c337a90, AppLocalizations.of(context)!.workout_f7c7e985, AppLocalizations.of(context)!.workout_f3949316, AppLocalizations.of(context)!.workout_404e46d1, AppLocalizations.of(context)!.workout_6b330584],
    AppLocalizations.of(context)!.bodyPartTriceps: [AppLocalizations.of(context)!.exercise_636fb74f, AppLocalizations.of(context)!.exercise_cba215fa, AppLocalizations.of(context)!.workout_41ae2e59, AppLocalizations.of(context)!.exerciseSkullCrusher, AppLocalizations.of(context)!.workout_f00eef45, AppLocalizations.of(context)!.exerciseDips, AppLocalizations.of(context)!.workout_4a6fa58a, AppLocalizations.of(context)!.exerciseKickback, AppLocalizations.of(context)!.exercise_a60f616c, AppLocalizations.of(context)!.workout_06bbf6c9, AppLocalizations.of(context)!.exercise_f48ee2b4, AppLocalizations.of(context)!.workout_7e5aac14, AppLocalizations.of(context)!.exercise_235597fb, AppLocalizations.of(context)!.workout_8a9a2d2b, AppLocalizations.of(context)!.workout_facbc0fc, AppLocalizations.of(context)!.workout_db390755],
    AppLocalizations.of(context)!.bodyPart_ceb49fa1: [AppLocalizations.of(context)!.crunch, AppLocalizations.of(context)!.legRaise, AppLocalizations.of(context)!.hangingLegRaise, AppLocalizations.of(context)!.plank, AppLocalizations.of(context)!.sidePlank, AppLocalizations.of(context)!.abRoller, AppLocalizations.of(context)!.cableCrunch, AppLocalizations.of(context)!.bicycleCrunch, AppLocalizations.of(context)!.workout_b2d699ea, AppLocalizations.of(context)!.workout_9bee258f, AppLocalizations.of(context)!.workout_eebef32f, AppLocalizations.of(context)!.workout_5be61342],
    AppLocalizations.of(context)!.exerciseCardio: [AppLocalizations.of(context)!.exerciseRunning, AppLocalizations.of(context)!.workout_f7a7208d, AppLocalizations.of(context)!.workout_285aeb0d, AppLocalizations.of(context)!.workout_f62c28a0, AppLocalizations.of(context)!.workout_cf6a6f5b, AppLocalizations.of(context)!.exerciseAerobicBike, AppLocalizations.of(context)!.workout_f4ecb3c9, AppLocalizations.of(context)!.workout_a90ed9c4, AppLocalizations.of(context)!.workout_4c6d7db7, AppLocalizations.of(context)!.workout_e23f084e, AppLocalizations.of(context)!.workout_9114559c, AppLocalizations.of(context)!.workout_aa4c3c64, AppLocalizations.of(context)!.workout_ba2fef80, AppLocalizations.of(context)!.workout_bc2d4a29, AppLocalizations.of(context)!.workout_fcdc095e, AppLocalizations.of(context)!.workout_9bee258f, AppLocalizations.of(context)!.workout_6180358f],
  };

  /// 種目名から部位を推定 (FIX: Problem 1 - Trim and normalize)
  /// 
  /// [exerciseName] 種目名（例: AppLocalizations.of(context)!.exerciseBenchPress, AppLocalizations.of(context)!.exerciseRunning）
  /// 
  /// Returns: 部位名（例: AppLocalizations.of(context)!.bodyPartChest, AppLocalizations.of(context)!.exerciseCardio）、見つからない場合は AppLocalizations.of(context)!.bodyPartOther
  static String getBodyPartByName(String exerciseName) {
    // スペースを除去して正規化
    final normalizedName = exerciseName.trim().replaceAll(' ', '');
    
    for (final entry in muscleGroupExercises.entries) {
      // マップ内の種目も正規化して比較
      if (entry.value.any((e) => e.replaceAll(' ', '') == normalizedName || exerciseName.contains(e))) {
        return entry.key;
      }
    }
    return AppLocalizations.of(context)!.bodyPartOther;
  }

  /// 有酸素運動かどうかを判定 (FIX: Problem 2 - Trim and normalize)
  static bool isCardioExercise(String exerciseName) {
    final normalizedName = exerciseName.trim().replaceAll(' ', '');
    final cardioList = muscleGroupExercises[AppLocalizations.of(context)!.exerciseCardio] ?? [];
    
    return cardioList.any((e) => e.replaceAll(' ', '') == normalizedName || exerciseName.contains(e));
  }

  /// 腹筋種目かどうかを判定
  static bool isAbsExercise(String exerciseName) {
    final normalizedName = exerciseName.trim().replaceAll(' ', '');
    final absList = muscleGroupExercises[AppLocalizations.of(context)!.bodyPart_ceb49fa1] ?? [];
    
    return absList.any((e) => e.replaceAll(' ', '') == normalizedName || exerciseName.contains(e));
  }

  /// 懸垂系種目かどうかを判定
  static bool isPullUpExercise(String exerciseName) {
    final pullUpVariations = [AppLocalizations.of(context)!.exercisePullUp, AppLocalizations.of(context)!.exerciseChinUp, AppLocalizations.of(context)!.workout_e3dc6687, AppLocalizations.of(context)!.workout_13a24951, AppLocalizations.of(context)!.workout_269bc3f6];
    return pullUpVariations.any((variation) => exerciseName.contains(variation));
  }

  /// 🔧 v1.0.249: 有酸素運動が距離を使うかどうかを判定
  /// 
  /// 距離を使う有酸素: ランニング、ジョギング、サイクリング、ウォーキング、水泳など
  /// 回数を使う有酸素: バーピー、マウンテンクライマー、バトルロープなど
  /// 
  /// [exerciseName] 種目名
  /// Returns: 距離を使う場合true、回数を使う場合false
  static bool cardioUsesDistance(String exerciseName) {
    final normalizedName = exerciseName.trim().replaceAll(' ', '');
    
    // 距離を使う有酸素運動
    final distanceExercises = [
      AppLocalizations.of(context)!.exerciseRunning,
      AppLocalizations.of(context)!.workout_f7a7208d,
      AppLocalizations.of(context)!.workout_285aeb0d,
      AppLocalizations.of(context)!.workout_f62c28a0,
      AppLocalizations.of(context)!.workout_cf6a6f5b,
      AppLocalizations.of(context)!.exerciseAerobicBike,
      AppLocalizations.of(context)!.workout_f4ecb3c9,
      AppLocalizations.of(context)!.workout_a90ed9c4,
      AppLocalizations.of(context)!.workout_4c6d7db7,
      AppLocalizations.of(context)!.workout_e23f084e,
      AppLocalizations.of(context)!.workout_9114559c,
      AppLocalizations.of(context)!.workout_aa4c3c64,
      AppLocalizations.of(context)!.workout_ba2fef80,
    ];
    
    return distanceExercises.any((e) => 
      e.replaceAll(' ', '') == normalizedName || exerciseName.contains(e));
  }
}
