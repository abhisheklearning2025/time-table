# Audio Alert Sounds

This directory contains audio files for activity alerts. Each category has its own sound file.

## Required Audio Files

The following MP3 files are required for the app to function properly:

### Category Sounds
- `study.mp3` - Study/Learning activities
- `work.mp3` - Work/Professional activities
- `chill.mp3` - Relaxation/Leisure activities
- `family.mp3` - Family time activities
- `fitness.mp3` - Exercise/Workout activities
- `sleep.mp3` - Sleep/Rest activities
- `food.mp3` - Meals/Eating activities
- `personal.mp3` - Personal care activities
- `social.mp3` - Social/Friends activities
- `creative.mp3` - Creative/Artistic activities
- `learning.mp3` - Learning/Study activities
- `health.mp3` - Health/Medical activities

### System Sounds
- `general.mp3` - Fallback sound for uncategorized activities
- `warning.mp3` - 5-minute warning before activity starts (softer sound)

## Audio File Specifications

- **Format**: MP3
- **Duration**: 3-10 seconds recommended
- **Volume**: Normalized (not too loud, AudioService handles volume control)
- **Sample Rate**: 44.1 kHz or 48 kHz
- **Bit Rate**: 128 kbps or higher

## Where to Get Audio Files

### Option 1: Free Sound Libraries
- **Freesound.org** - Creative Commons licensed sounds
- **Zapsplat.com** - Free sound effects
- **Mixkit.co** - Free music and sound effects
- **Pixabay** - Free stock audio

### Option 2: Generate Your Own
- Use text-to-speech tools
- Record simple notification sounds
- Use online tone generators

### Option 3: Use System Sounds
- Copy notification sounds from your device
- Use default ringtone/notification sounds

## Recommended Approach

For quick setup, you can:
1. Use the same audio file for all categories initially
2. Download a simple notification sound (e.g., gentle bell or chime)
3. Copy it 14 times with different names

Example using a single sound file:
```bash
# Download a notification sound as notification.mp3
# Then copy it for all categories:
cp notification.mp3 study.mp3
cp notification.mp3 work.mp3
cp notification.mp3 chill.mp3
# ... and so on for all 14 files
```

## Important Notes

- The app will validate audio assets on startup
- Missing audio files will cause errors when alerts trigger
- Custom audio paths (user-uploaded sounds) are stored separately
- The `warning.mp3` should be softer/different from regular alerts

## File Size Considerations

- Keep files under 500 KB each for faster loading
- Total size for all 14 files should be under 5 MB
- Compress audio if needed without losing quality

---

**Status**: 🔴 **AUDIO FILES NOT YET ADDED**
Please add the required audio files before testing Phase 5!
