#!/usr/bin/env node
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { currentCandidate } from './native-candidate.mjs';

export const acceptanceChecks = [
  'appearanceAndEditor',
  'agentSignals',
  'pluginsAndRevocation',
  'displayTopology',
  'touchID',
  'passwordRecovery',
  'trackpadPrivacy',
  'accessibility',
  'awakeAC',
  'awakeBattery',
];

export function assessAcceptance(report, executableSHA256) {
  const identityMatches = report?.executableSHA256 === executableSHA256;
  const identifiedEnvironment =
    typeof report?.macOS === 'string' &&
    report.macOS.trim().length > 0 &&
    typeof report?.hardware === 'string' &&
    report.hardware.trim().length > 0;
  const openChecks = acceptanceChecks.filter((key) => report?.checks?.[key] !== true);
  return {
    identityMatches,
    identifiedEnvironment,
    openChecks,
    readyForSigningReview: identityMatches && identifiedEnvironment && openChecks.length === 0,
    distributedBetaReady: false,
    boundary: 'Owner observations only. Signing, notarization and clean-Mac installation are separate gates.',
  };
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const { values } = parseArgs({ options: { template: { type: 'boolean' }, acceptance: { type: 'string' } } });
  const candidate = await currentCandidate();
  if (values.template) {
    console.log(
      JSON.stringify(
        {
          executableSHA256: candidate.executableSHA256,
          macOS: '',
          hardware: '',
          checks: Object.fromEntries(acceptanceChecks.map((key) => [key, null])),
        },
        null,
        2,
      ),
    );
  } else {
    const report = values.acceptance ? JSON.parse(await readFile(values.acceptance, 'utf8')) : null;
    const result = assessAcceptance(report, candidate.executableSHA256);
    console.log(JSON.stringify({ candidate: candidate.app, ...result }, null, 2));
    if (!result.readyForSigningReview) process.exitCode = 1;
  }
}
