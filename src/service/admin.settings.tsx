// src/services/adminSettings.service.ts
import { api } from '../utils/token.management';
import { SesManager } from '../utils/token.management';
import { type AdminSettings } from '../models/model';

export class AdminSettingsService {
  private base = api.defaults.baseURL ?? 'https://kaia.loophole.site';

  /** GET /admin/settings */
  async fetchAdminSettings(): Promise<AdminSettings> {
    try {
      const token = await SesManager.getJWTToken();

      // fallback mock quando não há sessão
      if (!token) {
        await new Promise((r) => setTimeout(r, 1000));
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

      // aceita {..} ou { data: {..} }
      const body = res.data?.data ?? res.data;
      return body as AdminSettings;
    } catch {
      // fallback mock
      return {
        pushNotifications: true,
        emailNotifications: false,
        theme: 'light',
        twoFactorEnabled: false,
      };
    }
  }

  /** PUT /admin/settings */
  async updateAdminSettings(settings: AdminSettings): Promise<AdminSettings> {
    try {
      const token = await SesManager.getJWTToken();

      if (!token) {
        await new Promise((r) => setTimeout(r, 500));
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
      await new Promise((r) => setTimeout(r, 500));
      return settings; // sucesso local em falha de rede
    }
  }
}
