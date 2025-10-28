// src/services/investor.service.ts
import { investorFromApi } from '../models/model';
import type { Investor } from '../models/model';

type Json = Record<string, any>;

const safeJson = (t: string): Json => {
  try { const v = JSON.parse(t); return v && typeof v === 'object' ? v : {}; }
  catch { return {}; }
};

export class InvestorService {
  constructor(private readonly baseUrl: string = 'https://kaia.loophole.site') {}

  async getAll(): Promise<Investor[]> {
    const uri = `${this.baseUrl}/investors`; // ajuste se o endpoint for outro
    const res = await fetch(uri, { headers: { Accept: 'application/json' } });
    const body = safeJson(await res.text());

    if (!res.ok) {
      const msg = typeof body.message === 'string' ? body.message : 'Falha ao carregar investidores';
      throw new Error(msg);
    }

    const arr: any[] = Array.isArray(body) ? body : Array.isArray(body?.data) ? body.data : [];
    return arr.map(investorFromApi);
  }

  // exemplo de getById, se precisar
  async getById(id: number): Promise<Investor> {
    const res = await fetch(`${this.baseUrl}/investors/${id}`, { headers: { Accept: 'application/json' } });
    const body = safeJson(await res.text());
    if (!res.ok) throw new Error(typeof body.message === 'string' ? body.message : 'Falha ao carregar investidor');
    return investorFromApi(body?.data ?? body);
  }
}
