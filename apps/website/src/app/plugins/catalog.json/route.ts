import { catalog } from '@/features/plugins/catalog';
export const dynamic = 'force-static';
export function GET() {
  return Response.json(catalog);
}
