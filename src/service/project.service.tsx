// src/services/project.service.ts
import { api } from '../service/apiclient.service';
import { SesManager } from '../utils/token.management';
import {
  projectFromApi,
  projectToApi,
  type Project,
} from '../models/model';

type Json = Record<string, any>;
const safeJson = (t: any): Json => (t && typeof t === 'object' ? t : {});

export class ProjectService {
  constructor(private readonly baseUrl: string = api.defaults.baseURL || 'https://kaia.loophole.site') {}

  private async auth() {
    const token = await SesManager.getJWTToken();
    return token ? { Authorization: `Bearer ${token}` } : {};
  }

  /** GET /projects/ */
  async listProjects(): Promise<Project[]> {
    const res = await api.get('/projects/', { headers: await this.auth() });
    const body = safeJson(res.data);

    const arr: any[] =
      Array.isArray(body) ? body :
      Array.isArray(body.projects) ? body.projects :
      Array.isArray(body.data) ? body.data : [];

    return arr.map(projectFromApi);
  }

  /** GET /projects/:id */
  async getProject(id: number): Promise<Project> {
    const res = await api.get(`/projects/${id}`, { headers: await this.auth() });
    const body = safeJson(res.data);
    return projectFromApi(body.data ?? body);
  }

  /** POST /projects/ (JSON) */
  async addProject(p: Project): Promise<Project> {
    // tenta preencher owner_id com payload salvo
    try {
      const payload = await SesManager.getPayload();
      if (payload?.id != null) p.ownerId = payload.id;
    } catch {}

    const res = await api.post('/projects/', projectToApi(p), {
      headers: await this.auth(),
    });
    const body = safeJson(res.data);
    return projectFromApi(body.data ?? body);
  }

  /**
   * POST /projects/ (multipart)
   * imagePath: URI local (file://, content://)
   */
  async addProjectWithImage(p: Project, imagePath: string): Promise<Project> {
    try {
      const payload = await SesManager.getPayload();
      if (payload?.id != null) p.ownerId = payload.id;
    } catch {}

    const fd = new FormData();
    const json = projectToApi(p);
    Object.entries(json).forEach(([k, v]) => {
      if (v !== undefined && v !== null) fd.append(k, String(v));
    });

    if (imagePath) {
      const name = imagePath.split('/').pop() || 'image.jpg';
      fd.append('image', {
      
        uri: imagePath,
        name,
        type: 'image/jpeg',
      });
    }

    const res = await api.post('/projects/', fd, {
      headers: { ...(await this.auth()), 'Content-Type': 'multipart/form-data' },
    });
    const body = safeJson(res.data);
    return projectFromApi(body.data ?? body);
  }

  /** DELETE /projects/:id */
  async deleteProject(id: number): Promise<void> {
    const res = await api.delete(`/projects/${id}`, { headers: await this.auth() });
    if (!(res.status === 200 || res.status === 204)) {
      throw new Error(`Erro ao deletar projeto: ${res.status}`);
    }
  }
}
