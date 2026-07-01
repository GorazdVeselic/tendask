-- Tendask — supplies tracking: allow a negative supply quantity (stock deficit).
--
-- Why: stock is an approximate log of reality, not an enforced inventory. When a
-- task consumes more than is on hand (a supply simply runs out), the on-device
-- quantity legitimately goes negative. The exact signed value must be kept so
-- reverting/deleting the task restores stock symmetrically (clamping at 0 would
-- leak phantom units on revert). The old CHECK (0001) then rejected the push and
-- — because push is fail-fast and `supply` is ordered before `task` — stalled
-- the ENTIRE sync (every later table stuck pending). Dropping the CHECK removes
-- that foot-gun.
--
-- Safe for old clients: shipped production builds have supplies disabled
-- (kSuppliesEnabled=false) and never write a negative quantity, so relaxing the
-- constraint changes nothing for them (a relaxation never breaks an old writer).
-- The UI clamps the displayed value at 0 (a deficit reads as "out"/low), while
-- the stored value stays exact.

alter table supply
  drop constraint if exists supply_quantity_check;
