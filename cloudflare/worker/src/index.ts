export interface Env {
  BACKUPS_BUCKET: R2Bucket;
  API_TOKEN: string;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    try {
      const url = new URL(request.url);
      const authHeader = request.headers.get('Authorization');

      // 1. Authentication
      if (!env.API_TOKEN || env.API_TOKEN.length < 8) {
        return new Response(JSON.stringify({ error: 'Server misconfigured: missing or weak API_TOKEN' }), { status: 500, headers: { 'Content-Type': 'application/json' } });
      }

      if (authHeader !== `Bearer ${env.API_TOKEN}`) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401, headers: { 'Content-Type': 'application/json' } });
      }

      const userId = request.headers.get('X-User-Id');
      if (!userId || userId.length < 8) {
        return new Response(JSON.stringify({ error: 'Missing or invalid X-User-Id header' }), { status: 400, headers: { 'Content-Type': 'application/json' } });
      }

      // 2. Routing
      const path = url.pathname;

      if (request.method === 'POST' && path === '/v1/backups') {
        return await handleUpload(request, env, userId);
      }
      
      if (request.method === 'GET' && path === '/v1/backups') {
        return await handleList(request, env, userId);
      }
      
      if (request.method === 'GET' && path.startsWith('/v1/backups/')) {
        const id = path.split('/').pop();
        return await handleDownload(request, env, userId, id!);
      }
      
      if (request.method === 'DELETE' && path.startsWith('/v1/backups/')) {
        const id = path.split('/').pop();
        return await handleDelete(request, env, userId, id!);
      }

      return new Response(JSON.stringify({ error: 'Not Found' }), { status: 404, headers: { 'Content-Type': 'application/json' } });
    } catch (e: any) {
      return new Response(JSON.stringify({ error: 'Internal Server Error', details: e.message }), { status: 500, headers: { 'Content-Type': 'application/json' } });
    }
  },
};

async function handleUpload(request: Request, env: Env, userId: string): Promise<Response> {
  const backupId = request.headers.get('X-Backup-Id');
  if (!backupId) {
    return new Response(JSON.stringify({ error: 'Missing X-Backup-Id' }), { status: 400, headers: { 'Content-Type': 'application/json' } });
  }

  const customMetadata: Record<string, string> = {
    'backup_id': backupId,
    'created_at': request.headers.get('X-Created-At') || new Date().toISOString(),
    'app_version': request.headers.get('X-App-Version') || 'unknown',
    'backup_format_version': request.headers.get('X-Backup-Format-Version') || '1',
    'schema_version': request.headers.get('X-Schema-Version') || '1',
    'checksum': request.headers.get('X-Checksum') || '',
    'encryption_version': request.headers.get('X-Encryption-Version') || '1',
  };

  const objectKey = `backups/${userId}/${backupId}.bin`;
  
  await env.BACKUPS_BUCKET.put(objectKey, await request.arrayBuffer(), {
    customMetadata,
  });

  return new Response(JSON.stringify({ message: 'Backup uploaded successfully', backup_id: backupId }), {
    status: 201,
    headers: { 'Content-Type': 'application/json' },
  });
}

async function handleList(request: Request, env: Env, userId: string): Promise<Response> {
  const prefix = `backups/${userId}/`;
  const listed = await env.BACKUPS_BUCKET.list({ prefix });

  const backups = listed.objects.map(obj => ({
    backup_id: obj.customMetadata?.['backup_id'] || obj.key.split('/').pop()?.replace('.bin', ''),
    size: obj.size,
    created_at: obj.customMetadata?.['created_at'],
    app_version: obj.customMetadata?.['app_version'],
    backup_format_version: obj.customMetadata?.['backup_format_version'],
    schema_version: obj.customMetadata?.['schema_version'],
    checksum: obj.customMetadata?.['checksum'],
    encryption_version: obj.customMetadata?.['encryption_version'],
  }));

  return new Response(JSON.stringify({ backups }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
}

async function handleDownload(request: Request, env: Env, userId: string, backupId: string): Promise<Response> {
  if (!backupId) return new Response(JSON.stringify({ error: 'Invalid backup ID' }), { status: 400 });

  const objectKey = `backups/${userId}/${backupId}.bin`;
  const object = await env.BACKUPS_BUCKET.get(objectKey);

  if (!object) {
    return new Response(JSON.stringify({ error: 'Backup not found' }), { status: 404, headers: { 'Content-Type': 'application/json' } });
  }

  const headers = new Headers();
  object.writeHttpMetadata(headers);
  headers.set('etag', object.httpEtag);
  if (object.customMetadata) {
    for (const [key, value] of Object.entries(object.customMetadata)) {
      headers.set(`X-${key.replace(/_/g, '-')}`, value);
    }
  }

  return new Response(object.body, {
    headers,
  });
}

async function handleDelete(request: Request, env: Env, userId: string, backupId: string): Promise<Response> {
  if (!backupId) return new Response(JSON.stringify({ error: 'Invalid backup ID' }), { status: 400 });

  const objectKey = `backups/${userId}/${backupId}.bin`;
  
  // R2 delete doesn't complain if object doesn't exist
  await env.BACKUPS_BUCKET.delete(objectKey);

  return new Response(JSON.stringify({ message: 'Backup deleted' }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
}