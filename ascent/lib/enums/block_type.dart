enum BlockType { main, superset, conditioning }

BlockType blockTypeFromString(String s) {
  switch (s) {
    case 'superset': return BlockType.superset;
    case 'conditioning': return BlockType.conditioning;
    default: return BlockType.main;
  }
}

String blockTypeToString(BlockType t) {
  switch (t) {
    case BlockType.main: return 'main';
    case BlockType.superset: return 'superset';
    case BlockType.conditioning: return 'conditioning';
  }
}