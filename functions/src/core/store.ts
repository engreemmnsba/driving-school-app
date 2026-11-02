import type { Doc } from './types.js';

/**
 * Minimal transactional store. The Firestore adapter implements it with a
 * real transaction; tests use MemoryStore. All reads must happen before
 * writes inside a transaction (Firestore rule), so handlers read first.
 */
export interface Tx {
  get(path: string): Promise<Doc | undefined>;
  /** Equality filters only; small result sets (e.g. lessons of one enrollment). */
  query(collectionPath: string, where: Record<string, unknown>): Promise<Doc[]>;
  /** One string field between two values (inclusive), e.g. businessDate within a month. */
  queryRange(collectionPath: string, field: string, from: string, to: string): Promise<Doc[]>;
  set(path: string, data: Doc): void;
  merge(path: string, data: Doc): void;
}

export interface Store {
  runTransaction<T>(fn: (tx: Tx) => Promise<T>): Promise<T>;
}

/** In-memory store with copy-on-commit semantics, for tests. */
export class MemoryStore implements Store {
  data = new Map<string, Doc>();

  async runTransaction<T>(fn: (tx: Tx) => Promise<T>): Promise<T> {
    const writes = new Map<string, { mode: 'set' | 'merge'; data: Doc }>();
    const tx: Tx = {
      get: async (path) => {
        const d = this.data.get(path);
        return d ? structuredClone(d) : undefined;
      },
      query: async (col, where) => {
        const out: Doc[] = [];
        for (const [path, d] of this.data) {
          const parent = path.substring(0, path.lastIndexOf('/'));
          if (parent !== col) continue;
          if (Object.entries(where).every(([k, v]) => d[k] === v)) out.push(structuredClone(d));
        }
        return out;
      },
      queryRange: async (col, field, from, to) => {
        const out: Doc[] = [];
        for (const [path, d] of this.data) {
          if (path.substring(0, path.lastIndexOf('/')) !== col) continue;
          const v = d[field];
          if (typeof v === 'string' && v >= from && v <= to) out.push(structuredClone(d));
        }
        return out;
      },
      set: (path, data) => { writes.set(path, { mode: 'set', data: structuredClone(data) }); },
      merge: (path, data) => {
        const prev = writes.get(path);
        writes.set(path, { mode: prev?.mode ?? 'merge', data: { ...(prev?.data ?? {}), ...structuredClone(data) } });
      },
    };
    const result = await fn(tx); // throws → nothing committed
    for (const [path, w] of writes) {
      if (w.mode === 'set') this.data.set(path, w.data);
      else this.data.set(path, { ...(this.data.get(path) ?? {}), ...w.data });
    }
    return result;
  }
}
