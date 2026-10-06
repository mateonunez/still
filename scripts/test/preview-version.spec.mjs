import assert from 'node:assert/strict';
import { test } from 'node:test';
import { previewVersion } from '../preview-version.mjs';

test('preview versions preserve SemVer while projecting numeric bundle versions', () => {
  assert.deepEqual(previewVersion('0.1.0-preview.12'), {
    version: '0.1.0-preview.12',
    tag: 'v0.1.0-preview.12',
    bundleVersion: '0.1.0',
    build: '12',
  });
  for (const invalid of [
    '0.1.0',
    'v0.1.0-preview.1',
    '0.1.0-beta.1',
    '0.1.0-preview.0',
    '01.1.0-preview.1',
    '0.1.0-preview.01',
    '0.1.0-preview.1/../../',
    '0.1.0-preview.9007199254740992',
  ]) {
    assert.throws(() => previewVersion(invalid));
  }
});
