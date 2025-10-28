// src/services/investment.service.ts
import { api } from '../service/apiclient.service';
import { SesManager } from '../utils/token.management';
import { type Investment, investmentFromApi, investmentToApi } from '../models/model';

type J = Record<string, any>;
const normList = (d: any): any[] =>
  Array.isArray(d) ? d : Array.isArray(d?.data) ? d.data : [];

export class InvestmentService {
  private path = '/investments/';

  private async auth() {
    const token = await SesManager.getJWTToken();
    return token ? { Authorization: `Bearer ${token}` } : {};
  }

  async createInvestment(inv: Investment): Promise<Investment> {
    const res = await api.post(this.path, investmentToApi(inv), {
      headers: { ...(await this.auth()), 'Content-Type': 'application/json' },
    });
    const body: J = res.data?.data ?? res.data;
    return investmentFromApi(body);
  }

  async getById(id: number): Promise<Investment> {
    const res = await api.get(this.path + id, { headers: await this.auth() });
    const body: J = res.data?.data ?? res.data;
    return investmentFromApi(body);
  }

  async getAll(params: { limit?: number; offset?: number } = {}): Promise<Investment[]> {
    const res = await api.get(this.path, {
      params,
      headers: await this.auth(),
    });
    return normList(res.data).map(investmentFromApi);
  }

  async getByProjectID(projectId: number, params: { limit?: number; offset?: number } = {}): Promise<Investment[]> {
    const res = await api.get(`${this.path}project/${projectId}`, {
      params,
      headers: await this.auth(),
    });
    return normList(res.data).map(investmentFromApi);
  }

  async getByInvestorID(investorId: number, params: { limit?: number; offset?: number } = {}): Promise<Investment[]> {
    const res = await api.get(`${this.path}investor/${investorId}`, {
      params,
      headers: await this.auth(),
    });
    return normList(res.data).map(investmentFromApi);
  }

  async updateInvestment(inv: Investment): Promise<Investment> {
    if (!inv.id) throw new Error('ID obrigatório');
    const res = await api.put(this.path + inv.id, investmentToApi(inv), {
      headers: { ...(await this.auth()), 'Content-Type': 'application/json' },
    });
    const body: J = res.data?.data ?? res.data;
    return investmentFromApi(body);
  }

  async deleteInvestment(id: number): Promise<void> {
    await api.delete(this.path + id, { headers: await this.auth() });
  }
}
