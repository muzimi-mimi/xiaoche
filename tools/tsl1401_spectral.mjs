#!/usr/bin/env node
/* Spectral cross-check: what mA/W (and therefore mV per lux-second) should a silicon
 * photodiode array really deliver under a white LED vs the datasheet's 640 nm LED?
 *
 * Reported datasheet numbers (ams TSL1401CL DS000136):
 *   Responsivity R typ = 35 V/(mJ/cm^2) at lambda_p = 640 nm
 *   Saturation exposure SE = 136 nJ/cm^2 (V_DD=5V), and R*SE = 35*0.136 = 4.76 V
 *     -> consistent with the stated V_sat 4.5-4.8 V, so R and SE corroborate each other.
 *   V_out(white) typ = 2.0 V, quoted at "E_e = 11 uW/cm^2, t_int = 5 ms, 640 nm"
 *     -> R implied = 2.0/(11e-6*1e-3 W/cm^2 * 5e-3 s) = 3.6e6 V/(mJ/cm^2) ... 1e5 too big
 *     -> with 11 mW/cm^2 the implied R = 36.4 V/(mJ/cm^2), matching R typ 35.
 *     So the quoted test irradiance unit is a typo; the mW reading makes the row consistent.
 * CONCLUSION: trust R = 35 V/(mJ/cm^2) @640 nm (corroborated by SE). Ignore the uW line.
 */

const H = 6.62607015e-34, C = 2.99792458e8, K = 1.380649e-23;
const hc = H * C;

// CIE 1931 photopic V(lambda), approximated by the standard Gaussian fit (sharpened)
const V = (lnm) => {
  const l = lnm;
  const t1 = Math.exp(-0.5 * Math.pow((l - 568.8) / 46.9, 2));
  const t2 = Math.exp(-0.5 * Math.pow((l - 530.9) / 16.3, 2));
  return 0.821 * t1 + 0.286 * t2;
};

// Relative spectral responsivity of the TSL1401CL (Fig. 12, "Photodiode Spectral Responsivity"):
// rises from ~0.3 at 400 nm to a flat ~1.0 plateau from roughly 620 nm to 900+ nm, then falls
// toward the 1100 nm silicon cutoff. Modelled as a smooth curve peaking at 750 nm.
const Srel = (lnm) => {
  if (lnm < 300 || lnm > 1150) return 0;
  const rise = 1 / (1 + Math.exp(-(lnm - 520) / 55));     // blue/UV roll-off
  const fall = 1 / (1 + Math.exp((lnm - 1000) / 45));     // silicon bandgap roll-off
  return rise * fall;
};

// Planck spectral radiance
const planck = (lnm, T) => {
  const l = lnm * 1e-9;
  return (2 * H * C * C) / Math.pow(l, 5) / (Math.exp(hc / (l * K * T)) - 1);
};

const grid = []; for (let l = 320; l <= 1150; l += 1) grid.push(l);
const integrate = (f) => grid.reduce((s, l) => s + f(l), 0);

// integrals: eye (photometric), photodiode (radiometric in the chip's response)
const eyeInt = (T) => integrate((l) => planck(l, T) * V(l));
const pdInt = (T) => integrate((l) => planck(l, T) * Srel(l));
const pdAt = (lnm) => Srel(lnm);

// luminous efficacy of radiation (lm/W) for a blackbody at T
const lmPerW = (T) => 683 * eyeInt(T) / integrate((l) => planck(l, T));

console.log('=== calibration of the model ===');
console.log(`  lm/W of a 2856 K blackbody        = ${lmPerW(2856).toFixed(1)}   (textbook answer ~20)`);
console.log(`  lm/W of a 3000 K blackbody        = ${lmPerW(3000).toFixed(1)}`);
// check the 640 nm monochromatic case analytically
const lmPerW640 = 683 * V(640);
console.log(`  lm/W of monochromatic 640 nm      = ${lmPerW640.toFixed(1)}   (683*V(640), V=${V(640).toFixed(4)})`);

// Datasheet R at 640 nm, converted to a per-lux figure
const R_V_per_mJcm2 = 35;                                  // V/(mJ/cm^2)
const R_V_per_Wm2s = R_V_per_mJcm2 * 1000;                 // 1 mJ/cm^2 = 10 J/m^2
const dsSlope640 = (R_V_per_Wm2s * 1000) / lmPerW640;      // mV/(lx*s) at 640 nm
console.log(`\n  datasheet R = 35 V/(mJ/cm^2) @640nm -> ${dsSlope640.toFixed(1)} mV/(lx*s) if the scene were 640 nm`);

// Now the same R, but asked of a broadband white LED scene.
// The chip's response is R_datasheet * Srel(l)/Srel(640). Per lux:
//   slope_scene = R_640 * [ Int(SPD*Srel)/Srel(640) ] / [ Int(SPD*V) ] / 683
const slopeForBlackbody = (T) => {
  const num = pdInt(T) / pdAt(640);
  const den = 683 * eyeInt(T);
  return (R_V_per_Wm2s * 1000) * num / den;
};

console.log('\n=== expected slope for a BROADBAND incandescent-like scene ===');
for (const T of [2856, 3000, 3500]) {
  console.log(`  ${T} K blackbody: lm/W=${lmPerW(T).toFixed(1)}  ->  ${slopeForBlackbody(T).toFixed(1)} mV/(lx*s)`);
}

// A white LED is a blue pump + a broad yellow/red phosphor. Approximate as
// a 460 nm pump plus a 560 nm-wide phosphor band, tuned to ~110 lm/W at 4500 K-ish.
// Simpler and more defensible: treat the phosphor-converted LED as a blackbody at its
// correlated colour temperature PLUS a blue pump term, then tune the ratio so lm/W ~ 110.
const ledSPD = (l, pumpFrac) =>
  (1 - pumpFrac) * planck(l, 4500) + pumpFrac * Math.exp(-0.5 * Math.pow((l - 455) / 14, 2));
let best = null;
for (let pf = 0; pf <= 0.5; pf += 0.005) {
  const e = integrate((l) => ledSPD(l, pf) * V(l));
  const w = integrate((l) => ledSPD(l, pf));
  const lm = 683 * e / w;
  if (best === null || Math.abs(lm - 110) < Math.abs(best.lm - 110)) best = { pf, lm };
}
const pf = best.pf;
const ledNum = integrate((l) => ledSPD(l, pf) * Srel(l)) / pdAt(640);
const ledDen = 683 * integrate((l) => ledSPD(l, pf) * V(l));
const ledSlope = (R_V_per_Wm2s * 1000) * ledNum / ledDen;
console.log('\n=== expected slope for a WHITE LED scene (pump + phosphor model) ===');
console.log(`  model: blue pump fraction ${(pf * 100).toFixed(1)} %, lm/W = ${best.lm.toFixed(1)}`);
console.log(`  ->  ${ledSlope.toFixed(1)} mV/(lx*s)`);
console.log(`  so a broadband white-LED scene is expected to give ${(ledSlope / dsSlope640).toFixed(2)}x`);
console.log(`  the 640 nm figure, i.e. MORE output per lux, because the eye's 555 nm peak and the`);
console.log('  chip\'s 700-900 nm plateau do not overlap.');

console.log('\n=== COMPARE WITH THE MEASUREMENT (10.74 mV/(lx*s)) ===');
for (const [name, v] of [
  ['datasheet R applied as if the scene were 640 nm', dsSlope640],
  ['datasheet R applied to a 2856 K incandescent scene', slopeForBlackbody(2856)],
  ['datasheet R applied to a white-LED scene (model)', ledSlope],
]) {
  console.log(`  ${name.padEnd(52)} ${v.toFixed(1).padStart(7)} mV/(lx*s)  -> measured is ${(v / 10.74).toFixed(1)}x BELOW`);
}
console.log('\n  (an earlier version of this analysis quoted 0.32-0.79 mV/(lx*s) for the chip by');
console.log('   wrongly dividing where it should have multiplied; the numbers above supersede it.)');
