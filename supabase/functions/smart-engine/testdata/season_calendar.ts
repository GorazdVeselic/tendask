// GOLDEN — the year of suggestions the engine produces for the simulated garden
// (season_fixture.ts) on weather seed 1. Regenerate by running
// season_sim_test.ts: on mismatch it prints the current calendar to stdout,
// ready to paste back here.
//
// This is the calendar AFTER the ignore back-off (O7). Before it, the same
// garden produced 156 cards and 129 pushes, of which R3 alone was 102 cards and
// 95 pushes — the finding N25 that the simulation was built to look for. Two
// numbers are worth keeping in view:
//
//   * every guard key now sits at 1–4 cards a year, cadence rules included;
//   * the push mix inverted. R5 (sow, prune, feed, protect — the seasonal work
//     the feature exists for) went from 31 of 129 pushes to 25 of 38. The
//     useful rule stopped competing with the noisy one for the same channel.
//
// June, July, November and December are empty on purpose: nothing in this
// garden is due then, and before the back-off they carried five watering
// reminders each.
export const kSeasonCalendar = `# Koledar predlogov 2026-01-01 → 2026-12-31
# Vrt: trata + jablana + paradižnik + malina + bazilika (rastlinjak).
# Uporabnik v tem teku ne izvede nobenega predloga — zgornja meja emisij.
# Skupaj: 52 predlogov · 38 pushov · največ na dan: 3
# Pushi po pravilu: R5 ×25 · R3 ×8 · R2 ×3 · R6 ×2

## Po mesecih
2026-01  R3 R3:water/up:p-basil ×3
2026-02  R5 berries.treat.dormant/up:p-raspberry ×2 · R3 R3:water/up:p-basil ×1
2026-03  R3 R3:mow/ar:a-lawn ×2 · R5 berries.fertilize/up:p-raspberry ×2 · R5 fruit_tree.fertilize/up:p-apple ×2 · R5 lawn.lawn_weed_moss.moss/ar:a-lawn ×2 · R5 lawn.roll/ar:a-lawn ×1 · R5 lawn.scarify.spring/ar:a-lawn ×1 · R6 R6:sow/up:p-tomato ×1
2026-04  R3 R3:mow/ar:a-lawn ×2 · R5 lawn.fertilize.spring/ar:a-lawn ×2 · R5 lawn.overseed.spring/ar:a-lawn ×2 · R5 vegetable.sow.direct/up:p-tomato ×2 · R2 R2:fertilize/up:p-apple ×1 · R2 R2:mow/ar:a-lawn ×1 · R5 berries.fertilize/up:p-raspberry ×1 · R5 fruit_tree.fertilize/up:p-apple ×1 · R5 lawn.lawn_weed_moss.moss/ar:a-lawn ×1 · R5 lawn.lawn_weed_moss.weed/ar:a-lawn ×1 · R5 lawn.scarify.spring/ar:a-lawn ×1 · R5 tomato.harden_off/up:p-tomato ×1 · R5 vegetable.plant/up:p-tomato ×1 · R6 R6:sow/up:p-tomato ×1
2026-05  R5 lawn.lawn_weed_moss.weed/ar:a-lawn ×2 · R2 R2:mow/ar:a-lawn ×1 · R5 vegetable.plant/up:p-tomato ×1 · R5 vegetable.sow.direct/up:p-tomato ×1
2026-06  —
2026-07  —
2026-08  R5 lawn.overseed.autumn/ar:a-lawn ×2
2026-09  R5 lawn.aerate/ar:a-lawn ×2 · R5 lawn.fertilize.autumn/ar:a-lawn ×2 · R5 lawn.scarify.autumn/ar:a-lawn ×2 · R2 R2:scarify/ar:a-lawn ×1 · R5 lawn.overseed.autumn/ar:a-lawn ×1
2026-10  R5 lawn.aerate/ar:a-lawn ×1 · R5 lawn.fertilize.autumn/ar:a-lawn ×1
2026-11  —
2026-12  —

## Na leto, po straži (guard_key/subject)
   4× R3 R3:mow/ar:a-lawn
   4× R3 R3:water/up:p-basil
   3× R5 berries.fertilize/up:p-raspberry
   3× R5 fruit_tree.fertilize/up:p-apple
   3× R5 lawn.aerate/ar:a-lawn
   3× R5 lawn.fertilize.autumn/ar:a-lawn
   3× R5 lawn.lawn_weed_moss.moss/ar:a-lawn
   3× R5 lawn.lawn_weed_moss.weed/ar:a-lawn
   3× R5 lawn.overseed.autumn/ar:a-lawn
   3× R5 vegetable.sow.direct/up:p-tomato
   2× R2 R2:mow/ar:a-lawn
   2× R5 berries.treat.dormant/up:p-raspberry
   2× R5 lawn.fertilize.spring/ar:a-lawn
   2× R5 lawn.overseed.spring/ar:a-lawn
   2× R5 lawn.scarify.autumn/ar:a-lawn
   2× R5 lawn.scarify.spring/ar:a-lawn
   2× R5 vegetable.plant/up:p-tomato
   2× R6 R6:sow/up:p-tomato
   1× R2 R2:fertilize/up:p-apple
   1× R2 R2:scarify/ar:a-lawn
   1× R5 lawn.roll/ar:a-lawn
   1× R5 tomato.harden_off/up:p-tomato`;
