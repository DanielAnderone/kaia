// src/services/payment.service.ts
type Json = Record<string, any>;

export type PaymentRequest = {
  id?: number;                // padrão 0
  payerFromId: number;
  payerToId: number;
  paidAmount: number;
  totalAmount: number;
  createdAt?: Date;           // padrão now
  updatedAt?: Date | null;    // se ausente, usa createdAt
};

const iso = (d?: Date | null) => (d ? d.toISOString() : undefined);

const paymentRequestToApi = (r: PaymentRequest) => {
  const created = r.createdAt ?? new Date();
  return {
    id: r.id ?? 0,
    payer_from_id: r.payerFromId,
    payer_to_id: r.payerToId,
    paid_amount: r.paidAmount,
    total_amount: r.totalAmount,
    created_at: iso(created),
    updated_at: iso(r.updatedAt ?? created),
  };
};

const safeJson = async (res: Response): Promise<Json> => {
  const text = await res.text();
  try {
    const obj = JSON.parse(text);
    return obj && typeof obj === 'object' ? obj : {};
  } catch {
    return {};
  }
};

export class PaymentService {
  constructor(private readonly baseUrl: string = 'https://kaia.loophole.site') {}

  /** POST /payments/ — retorna o corpo bruto do backend (map) */
  async createPayment(req: PaymentRequest): Promise<Json> {
    const url = `${this.baseUrl}/payments/`;
    const body = paymentRequestToApi(req);

    // logs úteis
    // eslint-disable-next-line no-console
    console.log('POST', url, '\npayload:', JSON.stringify(body));

    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
      body: JSON.stringify(body),
    });

    // eslint-disable-next-line no-console
    console.log('status:', res.status);

    const data = await safeJson(res);
    // eslint-disable-next-line no-console
    console.log('body:', data);

    if (res.ok) {
      return typeof data === 'object' && data != null ? data : { ok: true };
    }

    const msg =
      typeof (data as any)?.message === 'string'
        ? (data as any).message
        : `Falha ao processar pagamento (${res.status})`;
    throw new Error(msg);
  }
}
