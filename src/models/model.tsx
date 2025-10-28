
/* Helpers */
const toInt = (v: unknown, d = 0) =>
  typeof v === 'number' ? Math.trunc(v) : Number.parseInt(String(v ?? ''), 10) || d;

const toNum = (v: unknown, d = 0) =>
  typeof v === 'number' ? v : Number.parseFloat(String(v ?? '')) || d;

const toStr = (v: unknown, d = '') => (v == null ? d : String(v));
const toDate = (v: unknown): Date | null => {
  if (!v) return null;
  const d = new Date(String(v));
  return Number.isNaN(d.getTime()) ? null : d;
};
const iso = (d?: Date | null) => (d ? d.toISOString() : undefined);

/*
   ADMIN
 */
export type AdminProfile = {
  name: string;
  phoneNumber: string;
  dateOfBirth: string;
  profileImage: string;
};

export const adminProfileFromApi = (j: any): AdminProfile => ({
  name: toStr(j?.name),
  phoneNumber: toStr(j?.phone_number),
  dateOfBirth: toStr(j?.date_of_birth),
  profileImage: toStr(j?.profile_image),
});

export const adminProfileToApi = (m: AdminProfile) => ({
  name: m.name,
  phone_number: m.phoneNumber,
  date_of_birth: m.dateOfBirth,
  profile_image: m.profileImage,
});

export type AdminSettings = {
  pushNotifications: boolean;
  emailNotifications: boolean;
  theme: string;
  twoFactorEnabled: boolean;
};

export const adminSettingsFromApi = (j: any): AdminSettings => ({
  pushNotifications: j?.pushNotifications === true,
  emailNotifications: j?.emailNotifications === true,
  theme: toStr(j?.theme, 'light'),
  twoFactorEnabled: j?.twoFactorEnabled === true,
});

export const adminSettingsToApi = (m: AdminSettings) => ({
  pushNotifications: m.pushNotifications,
  emailNotifications: m.emailNotifications,
  theme: m.theme,
  twoFactorEnabled: m.twoFactorEnabled,
});

export type AdminStats = {
  title: string;
  value: string;
  icon: string;
};

/*
   AUTH
 */
export type AuthRequest = {
  email: string;
  password: string;
};

export const authRequestToApi = (m: AuthRequest) => ({
  email: m.email.trim(),
  password: m.password,
});

export type User = {
  id: number;
  username: string;
  email: string;
  role: string;
  status: string;
  lastLogin?: Date | null;
  createdAt: Date;
  updatedAt: Date;
};

export const userFromApi = (j: any): User => ({
  id: toInt(j?.id),
  username: toStr(j?.username),
  email: toStr(j?.email),
  role: toStr(j?.role || 'user'),
  status: toStr(j?.status || 'active'),
  lastLogin: toDate(j?.last_login),
  createdAt: toDate(j?.created_at) ?? new Date(),
  updatedAt: toDate(j?.updated_at) ?? new Date(),
});

export const userToApi = (m: User) => ({
  id: m.id,
  username: m.username,
  email: m.email,
  role: m.role,
  status: m.status,
  last_login: iso(m.lastLogin ?? undefined),
  created_at: iso(m.createdAt),
  updated_at: iso(m.updatedAt),
});

export type AuthResponse = {
  token: string;
  user: User;
};

export const authResponseFromApi = (j: any): AuthResponse => ({
  token: toStr(j?.token),
  user: userFromApi(j?.user ?? {}),
});

export const authResponseToApi = (m: AuthResponse) => ({
  token: m.token,
  user: userToApi(m.user),
});

/*
   INVESTIMENTO / INVESTIDOR
*/
export type Investment = {
  id: number;
  projectId: number;
  investorId: number;
  investedAmount: number;
  applicationDate: Date;
  estimatedProfit: number;
  actualProfit: number;
  note?: string | null;
  createdAt: Date;
  updatedAt?: Date | null;
};

export const investmentFromApi = (j: any): Investment => ({
  id: toInt(j?.id),
  projectId: toInt(j?.project_id),
  investorId: toInt(j?.investor_id),
  investedAmount: toNum(j?.invested_amount),
  applicationDate: toDate(j?.application_date) ?? new Date(),
  estimatedProfit: toNum(j?.estimated_profit),
  actualProfit: toNum(j?.actual_profit),
  note: j?.note == null ? null : toStr(j?.note),
  createdAt: toDate(j?.created_at) ?? new Date(),
  updatedAt: toDate(j?.updated_at),
});

export const investmentToApi = (m: Investment) => ({
  id: m.id,
  project_id: m.projectId,
  investor_id: m.investorId,
  invested_amount: m.investedAmount,
  application_date: iso(m.applicationDate),
  estimated_profit: m.estimatedProfit,
  actual_profit: m.actualProfit,
  note: m.note ?? undefined,
  created_at: iso(m.createdAt),
  updated_at: iso(m.updatedAt ?? undefined),
});

export type Investor = {
  id?: number | null;
  userId: number;
  name: string;
  phone: string;
  bornDate: Date;
  identityCard: string;
  nuit: string;
  createdAt?: Date | null;
  updatedAt?: Date | null;
};

export const investorFromApi = (j: any): Investor => ({
  id: j?.id == null ? null : toInt(j?.id),
  userId: toInt(j?.user_id),
  name: toStr(j?.name),
  phone: toStr(j?.phone),
  bornDate: toDate(j?.born_date) ?? new Date(),
  identityCard: toStr(j?.identity_card),
  nuit: toStr(j?.nuit),
  createdAt: toDate(j?.created_at),
  updatedAt: toDate(j?.updated_at),
});

export const investorToApi = (m: Investor) => ({
  id: m.id ?? undefined,
  user_id: m.userId,
  name: m.name,
  phone: m.phone,
  born_date: iso(m.bornDate),
  identity_card: m.identityCard,
  nuit: m.nuit,
});

/*
   PAGAMENTO / TRANSAÇÃO
 */
export type Payment = {
  id: number;
  payerFromId: number;
  payerToId: number;
  paidAmount: number;
  createdAt: Date;
  updatedAt?: Date | null;
};

export const paymentFromApi = (j: any): Payment => ({
  id: toInt(j?.id),
  payerFromId: toInt(j?.payer_from_id),
  payerToId: toInt(j?.payer_to_id),
  paidAmount: toNum(j?.paid_amount),
  createdAt: toDate(j?.created_at) ?? new Date(),
  updatedAt: toDate(j?.updated_at),
});

export const paymentToApi = (m: Payment) => ({
  id: m.id,
  payer_from_id: m.payerFromId,
  payer_to_id: m.payerToId,
  paid_amount: m.paidAmount,
  created_at: iso(m.createdAt),
  updated_at: iso(m.updatedAt ?? undefined),
});

export type Transaction = {
  id?: number | null;
  paymentId: number;
  investorId: number;
  payerAccount: string;
  gatewayRef: string;      // pode vir número no JSON
  transactionId: string;   // pode vir número no JSON
  amount: number;
};

export const transactionFromApi = (j: any): Transaction => ({
  id: j?.id == null ? null : toInt(j?.id),
  paymentId: toInt(j?.payment_id),
  investorId: toInt(j?.investor_id),
  payerAccount: toStr(j?.payer_account),
  gatewayRef: toStr(j?.gateway_ref),
  transactionId: toStr(j?.transaction_id),
  amount: toNum(j?.amount),
});

export const transactionToApi = (m: Transaction) => ({
  id: m.id ?? undefined,
  payment_id: m.paymentId,
  investor_id: m.investorId,
  payer_account: m.payerAccount,
  gateway_ref: Number.isFinite(Number(m.gatewayRef))
    ? Number(m.gatewayRef)
    : m.gatewayRef,
  transaction_id: Number.isFinite(Number(m.transactionId))
    ? Number(m.transactionId)
    : m.transactionId,
  amount: m.amount,
});

/*
   PROJETO
 */
export type Project = {
  id?: number | null;
  ownerId?: number | null;
  description?: string | null;
  startDate?: Date | null;
  endDate?: Date | null;
  profitabilityPercent: number;
  minimumInvestment: number;
  riskLevel?: string | null;
  status?: string | null;
  mediaPath?: string | null;
  investmentAchieved?: number | null;
  totalProfit?: number | null;
  createdAt?: Date | null;
  updatedAt?: Date | null;
};

export const projectFromApi = (j: any): Project => ({
  id: j?.id == null ? null : toInt(j?.id),
  ownerId: j?.owner_id == null ? null : toInt(j?.owner_id),
  description: j?.description == null ? null : toStr(j?.description),
  startDate: toDate(j?.start_date),
  endDate: toDate(j?.end_date),
  profitabilityPercent: toNum(j?.profitability_percent),
  minimumInvestment: toNum(j?.minimum_investment),
  riskLevel: j?.risk_level == null ? null : toStr(j?.risk_level),
  status: j?.status == null ? null : toStr(j?.status),
  mediaPath: j?.media_path == null ? null : toStr(j?.media_path),
  investmentAchieved:
    j?.investment_achieved == null ? null : toNum(j?.investment_achieved),
  totalProfit: j?.total_profit == null ? null : toNum(j?.total_profit),
  createdAt: toDate(j?.created_at),
  updatedAt: toDate(j?.updated_at),
});

export const projectToApi = (m: Project) => ({
  id: m.id ?? undefined,
  owner_id: m.ownerId ?? undefined,
  description: m.description ?? undefined,
  start_date: iso(m.startDate ?? undefined),
  end_date: iso(m.endDate ?? undefined),
  profitability_percent: m.profitabilityPercent,
  minimum_investment: m.minimumInvestment,
  risk_level: m.riskLevel ?? undefined,
  status: m.status ?? undefined,
  media_path: m.mediaPath ?? undefined,
  investment_achieved: m.investmentAchieved ?? undefined,
  total_profit: m.totalProfit ?? undefined,
  created_at: iso(m.createdAt ?? undefined),
  updated_at: iso(m.updatedAt ?? undefined),
});


 // ATIVIDADE RECENTE

export type RecentActivity = {
  icon: string;
  description: string;
  timeAgo: string;
};

