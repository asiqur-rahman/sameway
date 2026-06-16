/** Pluggable cache — memory for single node, Redis for horizontal scale. */
export interface ICacheStore {
  get<T>(key: string): Promise<T | undefined>;
  set<T>(key: string, value: T, ttlMs: number): Promise<void>;
  delete(key: string): Promise<void>;
  /** Remove keys starting with prefix (e.g. `search:`) without flushing geocode cache. */
  deleteByPrefix(prefix: string): Promise<void>;
  clear(): Promise<void>;
}
