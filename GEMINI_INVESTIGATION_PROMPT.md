# 🔍 Gemini Investigation Request: AI Coach Cardio Display Issue

## 📋 Issue Overview

**Problem**: After implementing the AI Coach feature with support for both cardio and strength training exercises, when exercises are saved to the workout log screen (`AddWorkoutScreen`), the display format becomes corrupted:

1. If cardio is entered first → All exercises (including strength training) show "distance/time" format
2. If strength training is entered first → All exercises (including cardio) show "weight/reps" format

**Expected Behavior**: Each exercise should display in its appropriate format:
- Cardio exercises: "distance (km) / time (min)"
- Strength training: "weight (kg) / reps (回)"

---

## 🔄 Implementation History

### ✅ Phase 1: Fixed AI Coach Screen Display (v1.0.237+261)
**Commit**: `5cdd8e1`

**Changes Made**:
1. Extended `ParsedExercise` class with cardio-specific fields:
```dart
class ParsedExercise {
  final String bodyPart;
  final String name;
  final double weight;
  final int reps;
  final int sets;
  final String description;
  final bool isCardio;      // ✅ NEW
  final double distance;     // ✅ NEW (km)
  final int duration;        // ✅ NEW (minutes)
}
```

2. Modified `_parseGeneratedMenu` to correctly identify cardio:
```dart
// Cardio detection based on bodyPart
final isCardio = bodyPart == '有酸素';

// Extract time for cardio (e.g., "10分", "20分")
if (isCardio) {
  final timeMatch = RegExp(r'(\d+)分').firstMatch(desc);
  if (timeMatch != null) {
    duration = int.parse(timeMatch.group(1)!);
    reps = duration;  // Use duration as reps for compatibility
  }
}
```

3. Updated UI display in AI Coach screen:
```dart
Widget _buildInfoChip(ParsedExercise exercise, int index) {
  if (exercise.isCardio) {
    return Text('${exercise.distance.toStringAsFixed(1)}km, ${exercise.duration}分');
  } else {
    return Text('${exercise.weight.toStringAsFixed(1)}kg, ${exercise.reps}回');
  }
}
```

**Result**: ✅ AI Coach screen now correctly displays mixed cardio + strength menus

---

### ❌ Phase 2: Attempted Fix for AddWorkoutScreen (CURRENT ISSUE)

**Problem**: The `AddWorkoutScreen` still shows incorrect formats because:

1. **`WorkoutSet` class lacks cardio fields**:
```dart
class WorkoutSet {
  final String exerciseName;
  double weight;
  int reps;
  bool isCompleted;
  bool hasAssist;
  SetType setType;
  
  // ❌ MISSING: isCardio, distance, duration fields
}
```

2. **Data transfer from AI Coach screen to AddWorkoutScreen is incomplete**:
```dart
// Current implementation in ai_coaching_screen_tabbed.dart
Navigator.pushNamed(
  context,
  '/add-workout',
  arguments: {
    'selectedExercises': selectedExercises,
    'userLevel': widget.userLevel,
    'exerciseHistory': widget.exerciseHistory,
  },
);
```
**Issue**: `selectedExercises` contains `ParsedExercise` objects with `isCardio`, `distance`, `duration`, but `AddWorkoutScreen` doesn't extract or use these fields.

3. **AddWorkoutScreen UI logic doesn't differentiate cardio vs strength**:
```dart
// Current _buildSetRow implementation
TextField(
  decoration: InputDecoration(
    labelText: '重量 (kg)',  // ❌ Always shows weight/reps
  ),
),
TextField(
  decoration: InputDecoration(
    labelText: '回数',
  ),
),
```

---

## 📦 Proposed Solution

### Step 1: Extend WorkoutSet Class

**File**: `lib/screens/workout/add_workout_screen_complete.dart`

```dart
class WorkoutSet {
  final String exerciseName;
  double weight;
  int reps;
  bool isCompleted;
  bool hasAssist;
  SetType setType;
  
  // ✅ ADD: Cardio-specific fields
  final bool isCardio;
  double distance;  // km
  int duration;     // minutes
  
  WorkoutSet({
    required this.exerciseName,
    this.weight = 0.0,
    this.reps = 10,
    this.isCompleted = false,
    this.hasAssist = false,
    this.setType = SetType.normal,
    this.isCardio = false,      // ✅ NEW
    this.distance = 0.0,         // ✅ NEW
    this.duration = 0,           // ✅ NEW
  });
}
```

### Step 2: Receive and Parse Arguments in AddWorkoutScreen

**File**: `lib/screens/workout/add_workout_screen_complete.dart`

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  
  // Get arguments passed from AI Coach screen
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  
  if (args != null && args.containsKey('selectedExercises')) {
    final selectedExercises = args['selectedExercises'] as List<dynamic>?;
    
    if (selectedExercises != null && _sets.isEmpty) {
      setState(() {
        for (var exercise in selectedExercises) {
          _sets.add(WorkoutSet(
            exerciseName: exercise.name,
            weight: exercise.isCardio ? 0.0 : exercise.weight,
            reps: exercise.isCardio ? exercise.duration : exercise.reps,
            isCardio: exercise.isCardio,           // ✅ TRANSFER
            distance: exercise.distance,            // ✅ TRANSFER
            duration: exercise.duration,            // ✅ TRANSFER
          ));
        }
        
        debugPrint('✅ AIコーチから${_sets.length}個のエクササイズを読み込みました');
      });
    }
  }
}
```

### Step 3: Dynamic UI Switching in _buildSetRow

**File**: `lib/screens/workout/add_workout_screen_complete.dart`

```dart
Widget _buildSetRow(int index) {
  final set = _sets[index];
  
  return Row(
    children: [
      // ✅ Dynamic label based on exercise type
      Expanded(
        child: TextField(
          controller: TextEditingController(
            text: set.isCardio 
              ? set.distance.toStringAsFixed(1)  // Distance for cardio
              : set.weight.toStringAsFixed(1),   // Weight for strength
          ),
          decoration: InputDecoration(
            labelText: set.isCardio ? '距離 (km)' : '重量 (kg)',  // ✅ SWITCH
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final numValue = double.tryParse(value) ?? 0.0;
            setState(() {
              if (set.isCardio) {
                set.distance = numValue;  // ✅ UPDATE DISTANCE
              } else {
                set.weight = numValue;    // ✅ UPDATE WEIGHT
              }
            });
          },
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: TextField(
          controller: TextEditingController(
            text: set.isCardio
              ? set.duration.toString()  // Duration for cardio
              : set.reps.toString(),     // Reps for strength
          ),
          decoration: InputDecoration(
            labelText: set.isCardio ? '時間 (分)' : '回数',  // ✅ SWITCH
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final intValue = int.tryParse(value) ?? 0;
            setState(() {
              if (set.isCardio) {
                set.duration = intValue;  // ✅ UPDATE DURATION
              } else {
                set.reps = intValue;      // ✅ UPDATE REPS
              }
            });
          },
        ),
      ),
    ],
  );
}
```

### Step 4: Save Cardio Data to Firestore

**File**: `lib/screens/workout/add_workout_screen_complete.dart`

```dart
Future<void> _saveWorkout() async {
  // ... existing validation code ...
  
  final setsData = _sets.map((set) {
    if (set.isCardio) {
      return {
        'exercise_name': set.exerciseName,
        'distance': set.distance,     // ✅ SAVE
        'duration': set.duration,     // ✅ SAVE
        'is_cardio': true,            // ✅ SAVE
        'is_completed': set.isCompleted,
      };
    } else {
      return {
        'exercise_name': set.exerciseName,
        'weight': set.weight,
        'reps': set.reps,
        'is_cardio': false,
        'set_type': set.setType.name,
        'has_assist': set.hasAssist,
        'is_completed': set.isCompleted,
      };
    }
  }).toList();
  
  await FirebaseFirestore.instance.collection('workout_logs').add({
    'user_id': user.uid,
    'date': Timestamp.fromDate(_selectedDate),
    'muscle_group': _selectedMuscleGroup,
    'sets': setsData,  // ✅ INCLUDES CARDIO DATA
    'memo': _memoController.text.trim(),
    'created_at': FieldValue.serverTimestamp(),
  });
}
```

---

## 🎯 Key Questions for Gemini

1. **Data Transfer**:
   - Is the `arguments` passing from `ai_coaching_screen_tabbed.dart` → `AddWorkoutScreen` correctly implemented?
   - Are `ParsedExercise` objects being properly received in `didChangeDependencies`?

2. **UI Logic**:
   - Is the `_buildSetRow` conditional rendering logic correct?
   - Are TextField controllers properly updating `distance`/`duration` for cardio and `weight`/`reps` for strength?

3. **State Management**:
   - Is `setState` being called appropriately when switching between cardio and strength exercises?
   - Are there any race conditions or timing issues with `didChangeDependencies`?

4. **Firestore Schema**:
   - Is the proposed Firestore save structure correct for mixed cardio/strength workouts?
   - Should we add additional fields for backward compatibility (e.g., fallback for old data)?

---

## 📂 Related Files

1. **AI Coach Screen**: `lib/screens/workout/ai_coaching_screen_tabbed.dart`
   - Contains `ParsedExercise` class (already fixed)
   - Navigates to AddWorkoutScreen with arguments

2. **Workout Log Screen**: `lib/screens/workout/add_workout_screen_complete.dart`
   - Contains `WorkoutSet` class (needs extension)
   - UI rendering logic (needs dynamic switching)

3. **Main Route**: `lib/main.dart`
   - Route definition for `/add-workout`

---

## 🧪 Test Cases

### Test 1: Mixed Menu (Cardio First)
**AI Generated Menu**:
- ランニング (有酸素): 5km, 30分
- ベンチプレス (胸): 80kg, 10回

**Expected Result in AddWorkoutScreen**:
- Row 1: `距離 (km): 5.0` | `時間 (分): 30`
- Row 2: `重量 (kg): 80.0` | `回数: 10`

### Test 2: Mixed Menu (Strength First)
**AI Generated Menu**:
- スクワット (脚): 100kg, 8回
- エアロバイク (有酸素): 10km, 45分

**Expected Result in AddWorkoutScreen**:
- Row 1: `重量 (kg): 100.0` | `回数: 8`
- Row 2: `距離 (km): 10.0` | `時間 (分): 45`

### Test 3: Manual Entry After AI Coach
**Steps**:
1. Load AI menu with cardio + strength
2. User manually adds another strength exercise
3. User manually adds another cardio exercise

**Expected Result**: All exercises maintain correct format independently

---

## 📊 Current Status

- ✅ **AI Coach Screen**: Correctly displays mixed menus (v1.0.237+261)
- ❌ **AddWorkoutScreen**: Displays incorrect format (CURRENT ISSUE)
- ⚠️ **Root Cause**: Data transfer and UI logic not implemented for cardio exercises

---

## 🚀 Next Steps

1. **Gemini Analysis**: Please review the proposed solution and identify any issues
2. **Code Implementation**: Apply fixes to `add_workout_screen_complete.dart`
3. **Testing**: Verify all test cases with mixed cardio/strength menus
4. **Version Update**: Release as v1.0.238+262 after confirmation

---

## 📝 Additional Context

**Scientific Basis**:
- Cardio is typically measured in **distance (km)** and **time (minutes)**
- Strength training is measured in **weight (kg)** and **reps (回)**
- Mixed training is common in fitness programs (concurrent training)

**User Flow**:
1. User opens AI Coach screen
2. AI generates mixed cardio + strength menu
3. User selects exercises and taps "トレーニング記録へ反映"
4. `AddWorkoutScreen` opens with pre-populated exercises
5. User adjusts values and saves to Firestore

**Critical Requirement**: The transition from Step 3 → Step 4 must preserve exercise type information (`isCardio` flag) for correct UI rendering.

---

## 🔗 Repository

**GitHub**: https://github.com/aka209859-max/gym-tracker-flutter
**Branch**: `main`
**Current Version**: v1.0.237+261
**Target Version**: v1.0.238+262

---

**End of Investigation Request**

Please analyze the proposed solution and provide detailed feedback on:
1. Whether the implementation approach is correct
2. Any potential issues or edge cases
3. Alternative solutions if the proposed approach has flaws
4. Specific code corrections needed

Thank you for your expertise! 🙏
