# Unity 3D Chess Board Setup Guide

## Overview

This guide explains how to set up the Unity 3D chess board that integrates with your Flutter ChessMate app via `flutter_unity_widget`.

## Architecture

```
┌─────────────────────┐        ┌──────────────────────┐
│   Flutter (Dart)    │        │   Unity (C#)          │
│                     │        │                       │
│  GameScreen         │───────>│  ChessGameManager     │
│  (UnityWidget)      │        │  ├─ MovePiece()       │
│                     │        │  ├─ ResetBoard()      │
│  GameProvider       │<───────│  └─ SetBoardFen()     │
│  (makeMoveFromAlg)  │        │                       │
└─────────────────────┘        └──────────────────────┘
     postMessage()           SendMessageToFlutter()
```

## Step-by-Step Unity Setup

### 1. Create a New Unity Project

1. Open **Unity Hub**
2. Click **New Project**
3. Choose **3D (Core)** template
4. Name it `ChessBoard3D`
5. Save it inside: `d:\Faiz\Codes\chessmate\unity\ChessBoard3D`

### 2. Import flutter_unity_widget Support

1. In Unity, go to **Window → Package Manager**
2. Click the **+** button → **Add package from git URL**
3. Add: `https://github.com/nicolgit/flutter_unity_widget_2022.git#master` (or the appropriate unity plugin for your version)
4. Alternatively, copy the `FlutterUnityIntegration` folder from the [flutter_unity_widget repo](https://github.com/nicolgit/flutter_unity_widget_2022) into your `Assets/` folder

### 3. Set Up the Scene

1. Open the default scene (or create a new one: **File → New Scene → Basic**)

2. **Create the ChessGameManager:**
   - Create an empty GameObject: **GameObject → Create Empty**
   - Rename it to **`ChessGameManager`** (⚠️ this name must match exactly!)
   - Drag the `ChessGameManager.cs` script onto this GameObject

3. **Set up the Camera:**
   - Select `Main Camera`
   - Position it to look down at the board:
     - Position: `(0, 8, -5)`
     - Rotation: `(60, 0, 0)`
   - Set Background color to dark (#0A0A0F): `RGB(10, 10, 15)`

4. **Create a Directional Light:**
   - Add warm directional light for pieces
   - Rotation: `(50, -30, 0)`
   - Color: Warm white `(255, 244, 230)`

### 4. Create 3D Chess Piece Models

You have three options:

#### Option A: Use Free Assets from Unity Asset Store
Search the Asset Store for "chess pieces 3D" — there are several free packs.

#### Option B: Use Primitive Shapes (Quick Start)
The script has fallback code that generates capsules if no prefabs are assigned. You can start with this and upgrade later.

#### Option C: Import Custom Models
1. Import your `.fbx` or `.obj` chess piece models into `Assets/Models/`
2. Create prefabs for each piece
3. Assign them in the `ChessGameManager` inspector:
   - **White Piece Prefabs**: `[Pawn, Knight, Bishop, Rook, Queen, King]`
   - **Black Piece Prefabs**: `[Pawn, Knight, Bishop, Rook, Queen, King]`

### 5. Create Board Square Prefabs

1. Create a Quad: **GameObject → 3D Object → Quad**
2. Scale it to `(1, 1, 1)` and rotate `(90, 0, 0)` to lie flat
3. Create two materials:
   - **LightSquare**: Color `#E8D5B0` (warm cream)
   - **DarkSquare**: Color `#6B4423` (dark brown)
4. Duplicate the Quad, assign each material
5. Drag them into `Assets/Prefabs/`
6. Assign to `ChessGameManager`:
   - **Light Square Prefab** → Light square
   - **Dark Square Prefab** → Dark square

### 6. Build Settings for Flutter

#### Android:
1. **File → Build Settings**
2. Switch platform to **Android**
3. Go to **Player Settings**:
   - Set **Minimum API Level** to **22** or higher
   - Set **Scripting Backend** to **IL2CPP**
   - Check **ARM64** under Target Architectures
4. Export as **Android Library** (check "Export Project")
5. Click **Export** — save to `d:\Faiz\Codes\chessmate\android\unityLibrary`

#### iOS:
1. Switch platform to **iOS**
2. Export as framework to `ios/UnityLibrary/`

### 7. Android Integration (build.gradle)

In your Flutter project's `android/settings.gradle`, add:
```gradle
include ':unityLibrary'
project(':unityLibrary').projectDir = file('./unityLibrary')
```

In `android/app/build.gradle`, add:
```gradle
dependencies {
    implementation project(':unityLibrary')
}
```

## Message Protocol

### Flutter → Unity

| Method | C# Function | Data | Description |
|--------|-------------|------|-------------|
| `postMessage('ChessGameManager', 'MovePiece', 'e2e4')` | `MovePiece(string)` | Algebraic move | Animate piece |
| `postMessage('ChessGameManager', 'ResetBoard', '')` | `ResetBoard(string)` | Empty | Reset to start |
| `postMessage('ChessGameManager', 'SetBoardFen', fen)` | `SetBoardFen(string)` | FEN string | Full board sync |

### Unity → Flutter

When a player drags a 3D piece, Unity sends the move string back:
```csharp
UnityMessageManager.Instance.SendMessageToFlutter("e2e4");
```

This triggers the `onUnityMessage` callback in Flutter's `UnityWidget`, which calls `notifier.makeMoveFromAlgebraic(moveStr)`.

## Testing

1. Build and export Unity project
2. Run `flutter run` on your device
3. The Unity 3D board should appear where the 2D board was
4. Drag pieces in 3D → Unity sends move to Flutter → Flutter validates → Flutter sends confirmed move back to Unity

## Troubleshooting

- **"ChessGameManager not found"**: Make sure the GameObject is named exactly `ChessGameManager`
- **Black screen**: Check Camera position and that the scene was exported correctly
- **Pieces not appearing**: Assign prefabs in the Inspector or let the fallback primitives work
- **Moves not syncing**: Check `debugPrint` logs on the Flutter side for Unity messages
