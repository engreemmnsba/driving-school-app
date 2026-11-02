import { defineConfig } from 'vitest/config';
// Security rules against the running Firestore emulator (npm run test:rules).
export default defineConfig({ test: { include: ['test-rules/**/*.test.ts'], testTimeout: 30000, hookTimeout: 60000, fileParallelism: false } });
