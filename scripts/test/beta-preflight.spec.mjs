import assert from 'node:assert/strict';
import { test } from 'node:test';
import { acceptanceChecks, assessAcceptance } from '../beta-preflight.mjs';

test('unknown checks and results from another candidate cannot pass signing review', () => {
  const report = {
    executableSHA256: 'old',
    macOS: '26.5.2',
    hardware: 'arm64',
    checks: Object.fromEntries(acceptanceChecks.map((key) => [key, true])),
  };
  assert.equal(assessAcceptance(report, 'current').readyForSigningReview, false);
  report.executableSHA256 = 'current';
  report.checks.trackpadPrivacy = 'true';
  assert.deepEqual(assessAcceptance(report, 'current').openChecks, ['trackpadPrivacy']);
  report.checks.trackpadPrivacy = true;
  assert.equal(assessAcceptance(report, 'current').readyForSigningReview, true);
  assert.equal(assessAcceptance(report, 'current').distributedBetaReady, false);
  assert.equal(assessAcceptance(null, 'current').readyForSigningReview, false);
  report.hardware = '';
  assert.equal(assessAcceptance(report, 'current').readyForSigningReview, false);
});
