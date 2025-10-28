// src/services/adminProfile.service.ts
import { api } from '../service/apiclient.service';
import { SesManager } from '../utils/token.management';
import {
  type AdminProfile,
  adminProfileFromApi,
  adminProfileToApi,
} from '../models/model';

const base = api.defaults.baseURL ?? 'https://api.seuprojeto.com';

export class AdminProfileService {
  /** GET /admin/profile */
  async fetchAdminProfile(): Promise<AdminProfile> {
    const token = await SesManager.getJWTToken();
    if (!token) throw new Error('Token não encontrado. Faça login.');

    const res = await api.get('/admin/profile', {
      baseURL: base,
      headers: { Authorization: `Bearer ${token}` },
    });

    const body = res.data?.data ?? res.data; // aceita {data:{...}} ou {...}
    return adminProfileFromApi(body);
  }

  /** PUT /admin/profile */
  async updateAdminProfile(admin: AdminProfile): Promise<void> {
    const token = await SesManager.getJWTToken();
    if (!token) throw new Error('Token não encontrado. Faça login.');

    await api.put('/admin/profile', adminProfileToApi(admin), {
      baseURL: base,
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    });
  }
}
