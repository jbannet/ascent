enum EnergySystemTag { easyAerobic, intervals, tempo }

EnergySystemTag energySystemFromString(String s) {
  switch (s) {
    case 'intervals': return EnergySystemTag.intervals;
    case 'tempo': return EnergySystemTag.tempo;
    default: return EnergySystemTag.easyAerobic;
  }
}

String energySystemToString(EnergySystemTag e) {
  switch (e) {
    case EnergySystemTag.easyAerobic: return 'easyAerobic';
    case EnergySystemTag.intervals: return 'intervals';
    case EnergySystemTag.tempo: return 'tempo';
  }
}