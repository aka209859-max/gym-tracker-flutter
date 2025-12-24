/// 種目マスターデータ
/// 種目名から部位を逆引きするための共通データ
class ExerciseMasterData {
  // 🔧 v1.0.243: 部位別種目マップ（add_workout_screen.dartから抽出）
  static const Map<String, List<String>> muscleGroupExercises = {
    AppLocalizations.of(context)!.bodyPartChest: [AppLocalizations.of(context)!.exerciseBenchPress, AppLocalizations.of(context)!.exerciseDumbbellPress, AppLocalizations.of(context)!.exerciseInclinePress, AppLocalizations.of(context)!.exercise_デクラインプレス, AppLocalizations.of(context)!.workout_ダンベルフライ, AppLocalizations.of(context)!.workout_インクラインフライ, AppLocalizations.of(context)!.workout_ケーブルクロスオーバー, AppLocalizations.of(context)!.exerciseCableFly, AppLocalizations.of(context)!.exerciseDips, AppLocalizations.of(context)!.exercise_チェストプレスマシン, AppLocalizations.of(context)!.workout_ペックフライマシン],
    AppLocalizations.of(context)!.bodyPartLegs: [AppLocalizations.of(context)!.exercise_バーベルスクワット, AppLocalizations.of(context)!.exercise_フロントスクワット, AppLocalizations.of(context)!.exercise_ブルガリアンスクワット, AppLocalizations.of(context)!.exerciseSquat, AppLocalizations.of(context)!.exerciseLegPress, AppLocalizations.of(context)!.exerciseLegExtension, AppLocalizations.of(context)!.exerciseLegCurl, AppLocalizations.of(context)!.exercise_ルーマニアンデッドリフト, AppLocalizations.of(context)!.workout_ランジ, AppLocalizations.of(context)!.workout_レッグアブダクション, AppLocalizations.of(context)!.workout_レッグアダクション, AppLocalizations.of(context)!.exerciseCalfRaise, AppLocalizations.of(context)!.workout_ヒップスラスト],
    AppLocalizations.of(context)!.bodyPartBack: [AppLocalizations.of(context)!.exerciseDeadlift, AppLocalizations.of(context)!.exerciseLatPulldown, AppLocalizations.of(context)!.workout_ラットプルダウンワイド, AppLocalizations.of(context)!.workout_ラットプルダウンナロー, AppLocalizations.of(context)!.exerciseChinUp, AppLocalizations.of(context)!.exercisePullUp, AppLocalizations.of(context)!.exerciseBentOverRow, AppLocalizations.of(context)!.workout_ワンハンドダンベルロウ, AppLocalizations.of(context)!.workout_Tバーロウ, AppLocalizations.of(context)!.exerciseSeatedRow, AppLocalizations.of(context)!.workout_ケーブルロウ, AppLocalizations.of(context)!.workout_バックエクステンション, AppLocalizations.of(context)!.workout_シュラッグ],
    AppLocalizations.of(context)!.bodyPartShoulders: [AppLocalizations.of(context)!.exerciseShoulderPress, AppLocalizations.of(context)!.exercise_ダンベルショルダープレス, AppLocalizations.of(context)!.exercise_マシンショルダープレス, AppLocalizations.of(context)!.exerciseSideRaise, AppLocalizations.of(context)!.workout_ケーブルサイドレイズ, AppLocalizations.of(context)!.exerciseFrontRaise, AppLocalizations.of(context)!.workout_リアレイズ, AppLocalizations.of(context)!.exerciseRearDeltFly, AppLocalizations.of(context)!.workout_ケーブルリアレイズ, AppLocalizations.of(context)!.exerciseUprightRow, AppLocalizations.of(context)!.workout_フェイスプル],
    AppLocalizations.of(context)!.bodyPartBiceps: [AppLocalizations.of(context)!.exerciseBarbellCurl, AppLocalizations.of(context)!.workout_EZバーカール, AppLocalizations.of(context)!.exerciseDumbbellCurl, AppLocalizations.of(context)!.workout_ダンベルカールオルタネイト, AppLocalizations.of(context)!.exerciseHammerCurl, AppLocalizations.of(context)!.exercisePreacherCurl, AppLocalizations.of(context)!.workout_インクラインダンベルカール, AppLocalizations.of(context)!.workout_コンセントレーションカール, AppLocalizations.of(context)!.exerciseCableCurl, AppLocalizations.of(context)!.workout_チンアップ逆手懸垂, AppLocalizations.of(context)!.workout_21カール, AppLocalizations.of(context)!.workout_ドラッグカール, AppLocalizations.of(context)!.workout_ゾットマンカール, AppLocalizations.of(context)!.workout_マシンアームカール],
    AppLocalizations.of(context)!.bodyPartTriceps: [AppLocalizations.of(context)!.exercise_トライセプスプレスダウン, AppLocalizations.of(context)!.exercise_ケーブルプレスダウン, AppLocalizations.of(context)!.workout_ライイングトライセプスエクステンション, AppLocalizations.of(context)!.exerciseSkullCrusher, AppLocalizations.of(context)!.workout_オーバーヘッドトライセプスエクステンション, AppLocalizations.of(context)!.exerciseDips, AppLocalizations.of(context)!.workout_トライセプスキックバック, AppLocalizations.of(context)!.exerciseKickback, AppLocalizations.of(context)!.exercise_クローズグリップベンチプレス, AppLocalizations.of(context)!.workout_ケーブルオーバーヘッドエクステンション, AppLocalizations.of(context)!.exercise_リバースグリッププレスダウン, AppLocalizations.of(context)!.workout_ダンベルトライセプスエクステンション, AppLocalizations.of(context)!.exercise_JMプレス, AppLocalizations.of(context)!.workout_ダイヤモンドプッシュアップ, AppLocalizations.of(context)!.workout_ベンチディップス, AppLocalizations.of(context)!.workout_マシンディップス],
    AppLocalizations.of(context)!.bodyPart_腹筋: [AppLocalizations.of(context)!.crunch, AppLocalizations.of(context)!.legRaise, AppLocalizations.of(context)!.hangingLegRaise, AppLocalizations.of(context)!.plank, AppLocalizations.of(context)!.sidePlank, AppLocalizations.of(context)!.abRoller, AppLocalizations.of(context)!.cableCrunch, AppLocalizations.of(context)!.bicycleCrunch, AppLocalizations.of(context)!.workout_ロシアンツイスト, AppLocalizations.of(context)!.workout_マウンテンクライマー, AppLocalizations.of(context)!.workout_ドラゴンフラッグ, AppLocalizations.of(context)!.workout_アブドミナルクランチマシン],
    AppLocalizations.of(context)!.exerciseCardio: [AppLocalizations.of(context)!.exerciseRunning, AppLocalizations.of(context)!.workout_ランニングトレッドミル, AppLocalizations.of(context)!.workout_ジョギング, AppLocalizations.of(context)!.workout_ジョギング屋外, AppLocalizations.of(context)!.workout_サイクリング, AppLocalizations.of(context)!.exerciseAerobicBike, AppLocalizations.of(context)!.workout_ステッパー, AppLocalizations.of(context)!.workout_水泳, AppLocalizations.of(context)!.workout_ローイングマシン, AppLocalizations.of(context)!.workout_ウォーキング, AppLocalizations.of(context)!.workout_ウォーキングトレッドミル, AppLocalizations.of(context)!.workout_インターバルラン, AppLocalizations.of(context)!.workout_クロストレーナー, AppLocalizations.of(context)!.workout_バトルロープ, AppLocalizations.of(context)!.workout_バーピージャンプ, AppLocalizations.of(context)!.workout_マウンテンクライマー, AppLocalizations.of(context)!.workout_マウンテンクライマー高強度],
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
    final absList = muscleGroupExercises[AppLocalizations.of(context)!.bodyPart_腹筋] ?? [];
    
    return absList.any((e) => e.replaceAll(' ', '') == normalizedName || exerciseName.contains(e));
  }

  /// 懸垂系種目かどうかを判定
  static bool isPullUpExercise(String exerciseName) {
    final pullUpVariations = [AppLocalizations.of(context)!.exercisePullUp, AppLocalizations.of(context)!.exerciseChinUp, AppLocalizations.of(context)!.workout_プルアップ, AppLocalizations.of(context)!.workout_チンアップ, AppLocalizations.of(context)!.workout_ワイドグリッププルアップ];
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
      AppLocalizations.of(context)!.workout_ランニングトレッドミル,
      AppLocalizations.of(context)!.workout_ジョギング,
      AppLocalizations.of(context)!.workout_ジョギング屋外,
      AppLocalizations.of(context)!.workout_サイクリング,
      AppLocalizations.of(context)!.exerciseAerobicBike,
      AppLocalizations.of(context)!.workout_ステッパー,
      AppLocalizations.of(context)!.workout_水泳,
      AppLocalizations.of(context)!.workout_ローイングマシン,
      AppLocalizations.of(context)!.workout_ウォーキング,
      AppLocalizations.of(context)!.workout_ウォーキングトレッドミル,
      AppLocalizations.of(context)!.workout_インターバルラン,
      AppLocalizations.of(context)!.workout_クロストレーナー,
    ];
    
    return distanceExercises.any((e) => 
      e.replaceAll(' ', '') == normalizedName || exerciseName.contains(e));
  }
}
