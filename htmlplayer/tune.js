function midiToFreq(midiNote) {
  // Standard tuning: MIDI note 69 is A4, which is 440 Hz
  return 440 * Math.pow(2, (midiNote - 69) / 12);
}

// Convert Game Boy pitch value to frequency in Hz
function gbPitchToFreq(n) {
  if (n < 0 || n > 2047) throw new RangeError("Game Boy pitch value must be between 0 and 2047");
  return 131072 / (2048 - n);
}

// Convert frequency in Hz to nearest Game Boy pitch value
function freqToGbPitch(freq) {
  if (freq <= 0) throw new RangeError("Frequency must be greater than 0");
  const n = 2048 - (131072 / freq);
  return Math.round(n); // Rounded to nearest valid pitch value
}
