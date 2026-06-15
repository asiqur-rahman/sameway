type CacheEntry<T> = { value: T; expiresAt: number };

/** Lightweight TTL cache for hot reads (system config, search bursts). */
export class MemoryCache<T> {
  private store = new Map<string, CacheEntry<T>>();

  constructor(private readonly defaultTtlMs: number) {}

  get(key: string): T | undefined {
    const entry = this.store.get(key);
    if (!entry) return undefined;
    if (Date.now() > entry.expiresAt) {
      this.store.delete(key);
      return undefined;
    }
    return entry.value;
  }

  set(key: string, value: T, ttlMs = this.defaultTtlMs) {
    this.store.set(key, { value, expiresAt: Date.now() + ttlMs });
  }

  delete(key: string) {
    this.store.delete(key);
  }

  clear() {
    this.store.clear();
  }

  /** Prevent unbounded growth under attack traffic. */
  prune(maxSize: number) {
    if (this.store.size <= maxSize) return;
    const overflow = this.store.size - maxSize;
    const keys = this.store.keys();
    for (let i = 0; i < overflow; i++) {
      const next = keys.next();
      if (next.done) break;
      this.store.delete(next.value);
    }
  }
}
