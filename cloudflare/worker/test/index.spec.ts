import { describe, it, expect, beforeAll } from 'vitest';
import { Miniflare } from 'miniflare';

const API_TOKEN = 'test-secret-token';
const USER_ID = 'user123456';

describe('Backup Worker', () => {
  let mf;

  beforeAll(() => {
    mf = new Miniflare({
      modules: true,
      scriptPath: './dist/index.mjs',
      r2Buckets: ['BACKUPS_BUCKET'],
      bindings: { API_TOKEN },
    });
  });

  it('rejects unauthenticated requests', async () => {
    const res = await mf.dispatchFetch('http://localhost/v1/backups', { method: 'GET' });
    expect(res.status).toBe(401);
  });

  it('rejects requests without X-User-Id', async () => {
    const res = await mf.dispatchFetch('http://localhost/v1/backups', { 
      method: 'GET',
      headers: { 'Authorization': `Bearer ${API_TOKEN}` }
    });
    expect(res.status).toBe(400);
  });

  it('handles full backup lifecycle', async () => {
    // 1. Upload
    let res = await mf.dispatchFetch('http://localhost/v1/backups', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${API_TOKEN}`,
        'X-User-Id': USER_ID,
        'X-Backup-Id': 'backup1',
        'X-Checksum': 'abcdef'
      },
      body: 'encrypted-data'
    });
    if(res.status !== 201) console.error(await res.json()); expect(res.status).toBe(201);

    // 2. List
    res = await mf.dispatchFetch('http://localhost/v1/backups', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${API_TOKEN}`,
        'X-User-Id': USER_ID,
      }
    });
    expect(res.status).toBe(200);
    let json = await res.json();
    expect(json.backups.length).toBe(1);
    expect(json.backups[0].backup_id).toBe('backup1');
    expect(json.backups[0].checksum).toBe('abcdef');

    // 3. Download
    res = await mf.dispatchFetch('http://localhost/v1/backups/backup1', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${API_TOKEN}`,
        'X-User-Id': USER_ID,
      }
    });
    expect(res.status).toBe(200);
    const body = await res.text();
    expect(body).toBe('encrypted-data');
    expect(res.headers.get('X-checksum')).toBe('abcdef');

    // 4. Delete
    res = await mf.dispatchFetch('http://localhost/v1/backups/backup1', {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${API_TOKEN}`,
        'X-User-Id': USER_ID,
      }
    });
    expect(res.status).toBe(200);

    // 5. List empty
    res = await mf.dispatchFetch('http://localhost/v1/backups', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${API_TOKEN}`,
        'X-User-Id': USER_ID,
      }
    });
    json = await res.json();
    expect(json.backups.length).toBe(0);
  });
});