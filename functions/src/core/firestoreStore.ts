import type { Firestore, Transaction } from 'firebase-admin/firestore';
import type { Store, Tx } from './store.js';
import type { Doc } from './types.js';

/** Store backed by a real Firestore transaction. */
export class FirestoreStore implements Store {
  constructor(private db: Firestore) {}

  runTransaction<T>(fn: (tx: Tx) => Promise<T>): Promise<T> {
    return this.db.runTransaction(async (t: Transaction) => {
      const tx: Tx = {
        get: async (path) => {
          const snap = await t.get(this.db.doc(path));
          return snap.exists ? (snap.data() as Doc) : undefined;
        },
        query: async (col, where) => {
          let q: FirebaseFirestore.Query = this.db.collection(col);
          for (const [k, v] of Object.entries(where)) q = q.where(k, '==', v);
          const snap = await t.get(q);
          return snap.docs.map((d) => d.data() as Doc);
        },
        queryRange: async (col, field, from, to) => {
          const snap = await t.get(this.db.collection(col).where(field, '>=', from).where(field, '<=', to));
          return snap.docs.map((d) => d.data() as Doc);
        },
        set: (path, data) => { t.set(this.db.doc(path), data); },
        merge: (path, data) => { t.set(this.db.doc(path), data, { merge: true }); },
      };
      return fn(tx);
    });
  }
}
