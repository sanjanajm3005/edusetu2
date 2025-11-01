



// NOTE: This code assumes you already have a ThemeManager (ThemeProvider) similar
// to your original project that exposes colors like primaryColor, secondaryColor,
// topContainerColor, etc. If names differ, adapt accordingly.


// Simple in-memory target manager (placeholder for SQLite integration later)
class TargetManager {
static final TargetManager _instance = TargetManager._internal();
factory TargetManager() => _instance;
TargetManager._internal();


int videosPerDay = 1;
int quizzesPerDay = 1;
int notesPerDay = 1;
}