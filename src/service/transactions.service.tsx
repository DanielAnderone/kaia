// src/services/transaction.service.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  transactionFromApi,
  transactionToApi,
  type Transaction,
} from '../models/model';

type Json = Record<string, any>;
const safeJson = (t: string): Json => {
  try { const v = JSON.parse(t); return v && typeof v === 'object' ? v : {}; }
  catch { return {}; }
};

export class TransactionService {
  constructor(private readonly baseUrl: string = 'https://kaia.loophole.site') {}

  /** POST /transactions */
  async createTransaction(tx: Transaction): Promise<Transaction> {
    const uri = `${this.baseUrl}/transactions`;
    const token = await AsyncStorage.getItem('auth_token');

    const res = await fetch(uri, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body: JSON.stringify(transactionToApi(tx)),
    });

    const body = safeJson(await res.text());
    if (!res.ok) {
      const msg = typeof body.message === 'string' ? body.message : 'Falha ao criar transação';
      throw new Error(msg);
    }

    const payload = body?.data ?? body;
    return transactionFromApi(payload);
  }

  /** GET /transactions */
  async list(): Promise<Transaction[]> {
    const uri = `${this.baseUrl}/transactions`;
    const token = await AsyncStorage.getItem('auth_token');

    const res = await fetch(uri, {
      headers: {
        Accept: 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
    });

    const body = safeJson(await res.text());
    if (!res.ok) {
      const msg = typeof body.message === 'string' ? body.message : 'Falha ao listar transações';
      throw new Error(msg);
    }

    const arr: any[] = Array.isArray(body) ? body : Array.isArray(body?.data) ? body.data : [];
    return arr.map(transactionFromApi);
  }

  /** Alias para compatibilidade com telas antigas */
  async getAll(): Promise<Transaction[]> {
    return this.list();
  }

  /** GET /transactions/:id */
  async getById(id: number | string): Promise<Transaction> {
    const uri = `${this.baseUrl}/transactions/${id}`;
    const token = await AsyncStorage.getItem('auth_token');

    const res = await fetch(uri, {
      headers: {
        Accept: 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
    });

    const body = safeJson(await res.text());
    if (!res.ok) {
      const msg = typeof body.message === 'string' ? body.message : 'Falha ao carregar transação';
      throw new Error(msg);
    }

    const payload = body?.data ?? body;
    return transactionFromApi(payload);
  }
}

export default TransactionService;
