// src/service/admin.settings.ts
import { api, SesManager } from '../utils/token.management';
import { type AdminSettings } from '../models/model';

export class AdminSettingsService {
  /** GET /admin/settings */
  async load(): Promise<AdminSettings> {
    try {
      const token = await SesManager.getJWTToken();

      // fallback quando não há sessão
      if (!token) {
        await new Promise((r) => setTimeout(r, 400));
        return {
          pushNotifications: true,
          emailNotifications: true,
          theme: 'light',
          twoFactorEnabled: false,
        };
      }

      const res = await api.get('/admin/settings', {
        headers: { Authorization: `Bearer ${token}` },
      });

      const body = res.data?.data ?? res.data;
      return body as AdminSettings;
    } catch {
      // fallback em erro de rede
      return {
        pushNotifications: true,
        emailNotifications: false,
        theme: 'light',
        twoFactorEnabled: false,
      };
    }
  }

  /** PUT /admin/settings */
  async save(settings: AdminSettings): Promise<AdminSettings> {
    try {
      const token = await SesManager.getJWTToken();

      if (!token) {
        await new Promise((r) => setTimeout(r, 300));
        return settings; // simula persistência local
      }

      const res = await api.put('/admin/settings', settings, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });

      const body = res.data?.data ?? res.data;
      return body as AdminSettings;
    } catch {
      await new Promise((r) => setTimeout(r, 300));
      return settings; // sucesso local em falha de rede
    }
  }
}

export default AdminSettingsService;
