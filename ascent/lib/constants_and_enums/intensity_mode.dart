enum IntensityMode { percent1rm, e1rm, rir, rpe, bandLevel, paceZone, heartRateZone }

IntensityMode intensityModeFromString(String s) {
  switch (s) {
    case 'percent1rm': return IntensityMode.percent1rm;
    case 'e1rm': return IntensityMode.e1rm;
    case 'rir': return IntensityMode.rir;
    case 'rpe': return IntensityMode.rpe;
    case 'bandLevel': return IntensityMode.bandLevel;
    case 'paceZone': return IntensityMode.paceZone;
    case 'heartRateZone': return IntensityMode.heartRateZone;
    default: return IntensityMode.rir;
  }
}