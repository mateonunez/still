import assert from 'node:assert/strict';
import { test } from 'node:test';
import { cpuSeconds, measure, utilization } from '../verify-native-cpu.mjs';

test('CPU observation handles minute/hour/day formats and measures one-core saturation', () => {
  assert.equal(cpuSeconds('12:18.36'), 738.36);
  assert.equal(cpuSeconds('1:02:03.50'), 3723.5);
  assert.equal(cpuSeconds('1-01:02:03'), 90123);
  assert.equal(utilization(10, 20, 10), 100);
  assert.equal(utilization(10, 10.5, 10), 5);
  assert.equal(utilization(10, 30, 10), 200);
  assert.throws(() => utilization(10, 9, 1));
  assert.throws(() => utilization(10, 10, 0));
  assert.throws(() => cpuSeconds('unavailable'));
  assert.throws(() => cpuSeconds('1:02:99'));
});

test('CPU probe rejects invalid durations and thresholds before observing a process', async () => {
  await assert.rejects(measure(123, { seconds: Number.NaN }));
  await assert.rejects(measure(123, { seconds: 2.5 }));
  await assert.rejects(measure(123, { maxPercent: Number.NaN }));
});
