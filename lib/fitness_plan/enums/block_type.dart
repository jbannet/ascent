enum BlockType { straight, superset, circuit, emom, interval, amrap, tempo, conditioning }

BlockType blockTypeFromString(String s) {
  switch (s) {
    case 'superset': return BlockType.superset;
    case 'conditioning': return BlockType.conditioning;
    case 'circuit': return BlockType.circuit;
    case 'emom': return BlockType.emom;
    case 'interval': return BlockType.interval;
    case 'amrap': return BlockType.amrap;
    case 'tempo': return BlockType.tempo;
    default: return BlockType.straight;
  }
}

String blockTypeToString(BlockType t) {
  switch (t) {
    case BlockType.straight: return 'straight';
    case BlockType.superset: return 'superset';
    case BlockType.circuit: return 'circuit';
    case BlockType.emom: return 'emom';
    case BlockType.interval: return 'interval';
    case BlockType.amrap: return 'amrap';
    case BlockType.tempo: return 'tempo';
    case BlockType.conditioning: return 'conditioning';
  }
}