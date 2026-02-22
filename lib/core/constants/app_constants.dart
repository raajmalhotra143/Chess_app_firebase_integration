import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color bg = Color(0xFF0A0A0F);
  static const Color bgCard = Color(0xFF13131A);
  static const Color bgSurface = Color(0xFF1C1C27);

  // Gold accent (from Stitch design)
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8C84A);
  static const Color goldDark = Color(0xFFAA8B22);

  // Teal / blue accent
  static const Color teal = Color(0xFF00C9B1);
  static const Color tealDark = Color(0xFF00857A);
  static const Color blue = Color(0xFF4A90D9);

  // Board colors (classic dark theme)
  static const Color boardLight = Color(0xFFE8D5B0);
  static const Color boardDark = Color(0xFF6B4423);
  static const Color boardLightAlt = Color(0xFFCDB16A);
  static const Color boardDarkAlt = Color(0xFF4A3520);

  // Piece colors
  static const Color pieceWhite = Color(0xFFF5F0E8);
  static const Color pieceBlack = Color(0xFF1A1A1A);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Text
  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textMuted = Color(0xFF6B6B80);

  // Highlight
  static const Color moveHighlight = Color(0x8000C9B1);
  static const Color selectedHighlight = Color(0x80D4AF37);
  static const Color lastMoveHighlight = Color(0x604A90D9);
  static const Color checkHighlight = Color(0xA0EF4444);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFAA8B22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00C9B1), Color(0xFF006B5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF13131A), Color(0xFF0D0D15)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppDimens {
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radius = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
  static const double radiusFull = 999.0;

  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double padding = 16.0;
  static const double paddingMd = 20.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;

  static const double iconSm = 20.0;
  static const double icon = 24.0;
  static const double iconMd = 32.0;
  static const double iconLg = 48.0;
  static const double iconXl = 64.0;
}

class AppStrings {
  static const String appName = 'ChessMate';
  static const String tagline = 'Master the Game. Rule the Board.';

  // Mode Select
  static const String playOnline = 'Online Multiplayer';
  static const String playOffline = 'Offline Mode';
  static const String playAI = 'Play vs AI';
  static const String playFriend = 'Play with Friend';

  // Auth
  static const String login = 'Log In';
  static const String register = 'Create Account';
  static const String forgotPassword = 'Forgot Password?';
  static const String googleSignIn = 'Continue with Google';

  // Game
  static const String resign = 'Resign';
  static const String drawRequest = 'Offer Draw';
  static const String rematch = 'Rematch';
  static const String newGame = 'New Game';
  static const String flipBoard = 'Flip Board';
  static const String undo = 'Undo';
}
