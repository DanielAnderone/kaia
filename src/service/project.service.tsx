import { api } from '../service/apiclient.service';
import { SesManager } from '../utils/token.management';
import {
  type Project,
  projectFromApi,
  projectToApi,
} from '../models/model';

type Json = Record<string, any>;
const j = (x: any): Json => (x && typeof x === 'object' ? x : {});
const asArr = (x: any): any[] => (Array.isArray(x) ? x : []);

/* --------- Cabeçalhos com token JWT --------- */
async function authHeaders(): Promise<Record<string, string>> {
  const token = await SesManager.getJWTToken();
  return token ? { Authorization: `Bearer ${token}` } : {};
}

/* ============================================
 *  PROJECT SERVICE
 * ========================================== */
export class ProjectService {
  private base = api.defaults.baseURL ?? '';

  /** GET /projects */
  async listProjects(): Promise<Project[]> {
    try {
      const res = await api.get('/projects', { headers: await authHeaders() });
      if (res.status !== 200)
        throw new Error(`Erro ao carregar projetos: ${res.status}`);

      const body = j(res.data);
      const arr: any[] = Array.isArray(body)
        ? body
        : asArr(body.projects) || asArr(body.data);

      return arr.map(projectFromApi);
    } catch (e: any) {
      throw new Error(`Erro de rede: ${e?.message || e}`);
    }
  }

  /** GET /projects/:id */
  async getProject(id: number): Promise<Project> {
    try {
      const res = await api.get(`/projects/${id}`, {
        headers: await authHeaders(),
      });
      if (res.status !== 200)
        throw new Error(`Erro ao buscar projeto: ${res.status}`);

      const body = j(res.data);
      return projectFromApi(body.data ?? body);
    } catch (e: any) {
      throw new Error(`Erro de rede: ${e?.message || e}`);
    }
  }

  /** Retorna URL de download da imagem do projeto */
  getImageUrl(id?: number | null): string | null {
    if (!id) return null;
    const base = this.base.replace(/\/+$/, '');
    return `${base}/projects/download/${id}`;
  }

  /** POST /projects (JSON) */
  async addProject(p: Project): Promise<Project> {
    try {
      const payload = await SesManager.getPayload().catch(() => null);
      if (payload?.id) p.ownerId = payload.id;

      const res = await api.post('/projects/', projectToApi(p), {
        headers: await authHeaders(),
      });

      if (![200, 201].includes(res.status))
        throw new Error(`Erro ao criar projeto: ${res.status}`);

      const body = j(res.data);
      return projectFromApi(body.data ?? body);
    } catch (e: any) {
      throw new Error(`Erro de rede: ${e?.message || e}`);
    }
  }

  /** POST /projects (multipart) */
  async addProjectWithImage(p: Project, imagePath: string): Promise<Project> {
    try {
      const payload = await SesManager.getPayload().catch(() => null);
      if (payload?.id) p.ownerId = payload.id;

      const fd = new FormData();
      const json = projectToApi(p);

      Object.entries(json).forEach(([k, v]) => {
        if (v !== undefined && v !== null)
          fd.append(k, typeof v === 'string' ? v : String(v));
      });

      if (imagePath) {
        const name = imagePath.split('/').pop() || 'image.jpg';
        // @ts-ignore
        fd.append('file', { uri: imagePath, name, type: 'image/jpeg' });
      }

      const res = await api.post('/projects/', fd, {
        headers: {
          ...(await authHeaders()),
          'Content-Type': 'multipart/form-data',
        },
      });

      if (![200, 201].includes(res.status))
        throw new Error(`Erro ao criar projeto: ${res.status}`);

      const body = j(res.data);
      return projectFromApi(body.data ?? body);
    } catch (e: any) {
      throw new Error(`Erro de rede: ${e?.message || e}`);
    }
  }

  /** DELETE /projects/:id */
  async deleteProject(id: number): Promise<void> {
    try {
      const res = await api.delete(`/projects/${id}`, {
        headers: await authHeaders(),
      });
      if (![200, 204].includes(res.status))
        throw new Error(`Erro ao deletar projeto: ${res.status}`);
    } catch (e: any) {
      throw new Error(`Erro de rede: ${e?.message || e}`);
    }
  }
}
