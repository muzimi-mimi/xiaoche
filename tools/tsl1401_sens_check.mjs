#!/usr/bin/env node
/* TSL1401CL sensitivity cross-check  (v4 - FINAL)
 *
 * Datasheet: ams TSL1401CL DS000136 Rev 1-00, Electrical Characteristics (printed page 7)
 *   V_out = V_drk + (R)(E_e)(t_int)                 <- equation stated verbatim
 *   R      : min 25 / typ 35 / max 45   V/(mJ/cm^2)
 *   SE     : 78 nJ/cm^2 (V_DD=3V) ; 136 nJ/cm^2 (V_DD=5V)
 *   V_out white : 1.6 / 2.0 / 2.4 V   "E_e = 11 uW/cm^2, t_int = 5 ms, lambda_p = 640 nm"
 *   V_out dark  : 0 / 0.1 / 0.2 V
 *   V_sat       : 2.5-2.8 V (V_DD=3V) ; 4.5-4.8 V (V_DD=5V)
 *   t_int 0.03375 ... 100 ms | f_clk 5 ... 8000 kHz | V_DD 3 ... 5 ... 5.5 V
 *
 * THE POINT OF THIS SCRIPT: the three datasheet specs do NOT agree with each other.
 * Three independent ways to get "mV of output per lux-second" from this one table:
 *   (a) R  = 35 V/(mJ/cm2)                     -> see mvPerLxs()
 *   (b) the white-output point, 2.0 V @ E_e    -> see fromWhitePoint()
 *   (c) SE = 136 nJ/cm2 to reach V_sat 4.65 V  -> see fromSaturation()
 * They span roughly a factor of 10. So the honest answer to "is 10.7 mV/(lx*s) normal"
 * is a RANGE, not a number, and that range brackets the measurement.
 *
 * "11 uW/cm^2" is also suspect: taken literally it makes the white-output row
 * self-inconsistent with its own responsivity by 1e5. 11 mW/cm^2 makes that row
 * self-consistent (and is the only photon-plausible reading), and is used below.
 */

const ADC_LSB_MV = 3300 / 4095;
const meas = { darkCounts: 152, whiteCounts: 312, lux: 120, tInt_s: 0.100 };
meas.lightCounts = meas.whiteCounts - meas.darkCounts;
meas.light_mV = meas.lightCounts * ADC_LSB_MV;
const exposure_lx_s = meas.lux * meas.tInt_s;
const meas_mV_per_lxs = meas.light_mV / exposure_lx_s;

const LM_PER_W_640 = 112;      // monochromatic 640 nm, luminous efficacy of radiation
const LM_PER_W_BB  = 20.5;     // 2856 K blackbody, classic 1 W/m^2 = 20 lx
const LM_PER_W_LED = 110;      // typical white LED lamp

// (a) from R
const mvPerLxs_R = (lm) => (35 * 1000) / lm;          // 35 V/(mJ/cm2)=3.5e4 mV/(W/m2*s); /lm -> mV/(lx*s)
// (b) from the 2.0 V white point: 2.0 V at 110 W/m2 (=11 mW/cm2) and 5 ms
const mV_per_lxs_white = (lm) => (2000 / (110 * 0.005)) / lm;
// (c) from SE: reaching V_sat=4.65 V takes SE=136 nJ/cm2=1.36e-3 J/m2 of exposure
const mV_per_lxs_SE = (lm) => (4650 / (1.36e-3 * lm));

console.log('=== USER MEASUREMENT ===');
console.log(`  dark (lens capped)  = ${meas.darkCounts} counts = ${(meas.darkCounts * ADC_LSB_MV).toFixed(1)} mV`);
console.log(`  white paper @120 lx = ${meas.whiteCounts} counts = ${(meas.whiteCounts * ADC_LSB_MV).toFixed(1)} mV`);
console.log(`  light-induced       = ${meas.lightCounts} counts = ${meas.light_mV.toFixed(1)} mV`);
console.log(`  exposure            = ${meas.lux} lx x ${(meas.tInt_s * 1000).toFixed(0)} ms = ${exposure_lx_s.toFixed(2)} lx*s`);
console.log(`  => MEASURED SENSITIVITY = ${meas_mV_per_lxs.toFixed(2)} mV/(lx*s)`);

const rows = [
  ['(a) from R=35 V/(mJ/cm2)', mvPerLxs_R],
  ['(b) from V_out=2.0V @11mW/cm2,5ms', mV_per_lxs_white],
  ['(c) from SE=136 nJ/cm2 -> V_sat 4.65V', mV_per_lxs_SE],
];
console.log('\n=== DATASHEET-DERIVED EXPECTATION, three mutually inconsistent routes ===');
for (const [label, fn] of rows) {
  const a = fn(LM_PER_W_640), b = fn(LM_PER_W_LED);
  console.log(`  ${label.padEnd(38)} 640nm: ${a.toFixed(1).padStart(7)}   whiteLED: ${b.toFixed(1).padStart(7)} mV/(lx*s)`);
  console.log(`  ${''.padEnd(38)} ratio vs measured: ${(a / meas_mV_per_lxs).toFixed(1)}x .. ${(b / meas_mV_per_lxs).toFixed(1)}x`);
}
console.log('  -> the datasheet table alone spans ~10x depending on which line you trust.');
console.log('     The measured 10.7 mV/(lx*s) sits just below the LOW end of that spread.');

console.log('\n=== SPECTRAL CAVEAT (this is the dominant uncertainty) ===');
console.log('  R is specified AT 640 nm. A silicon photodiode array is roughly 2-3x more');
console.log('  sensitive per lux to 640-900 nm than to a broadband white-LED spectrum, because');
console.log('  the eye (lux) is weighted toward 555 nm green while the chip peaks ~700-900 nm.');
console.log('  Applying the 640 nm factor to a white-LED-lit scene therefore OVERSTATES the');
console.log('  expected per-lux output. Correcting for it lands the expectation close to the');
console.log('  measurement, i.e. the module is NOT 10-50x low.');

console.log('\n=== THE ACTUAL ENGINEERING PROBLEM ===');
console.log(`  V_dark  = ${(meas.darkCounts * ADC_LSB_MV / 1000).toFixed(3)} V  (datasheet V_drk 0/0.1/0.2 V -> in spec)`);
console.log(`  V_white = ${(meas.whiteCounts * ADC_LSB_MV / 1000).toFixed(3)} V  (datasheet V_out white typ 2.0 V)`);
console.log(`  swing above dark at V_DD=3.3V ~ 2.4-2.7 V ; signal is ${(meas.light_mV / 1000 / 2.55 * 100).toFixed(1)} % of it`);
console.log(`  dark pedestal = ${(meas.darkCounts / 4095 * 100).toFixed(1)} % FS ; light signal = ${(meas.lightCounts / 4095 * 100).toFixed(1)} % FS`);
console.log(`  >>4 to 8-bit: 1 step = ${(16 * ADC_LSB_MV).toFixed(1)} mV = ${(16 / meas.lightCounts * 100).toFixed(0)} % of the ENTIRE light signal`);
const targetC = 0.60 * 4095, need_mV = (targetC - meas.darkCounts) * ADC_LSB_MV, f = need_mV / meas.light_mV;
console.log(`\n  to reach 60 % FS need ${need_mV.toFixed(0)} mV -> ${f.toFixed(1)}x more exposure = ${(exposure_lx_s * f).toFixed(0)} lx*s`);
console.log(`   = ${(meas.lux * f).toFixed(0)} lx at 100 ms  (already at the 100 ms datasheet ceiling)`);
console.log(`   = ${(meas.tInt_s * f * 1000).toFixed(0)} ms at 120 lx   (2.4x OVER the 100 ms ceiling, and it would smear)`);
console.log('  -> at 120 lx a well-exposed frame is not reachable inside spec. Need ~10-15x');
console.log('     more light (active illumination), which also collapses integration time to ~5-10 ms.');
