// src/services/auth.service.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import type { AuthRequest, AuthResponse, User } from '../models/model';
import { authRequestToApi, authResponseFromApi } from '../models/model';

type Json = Record<string, any>;

export class AuthService {
  constructor(private readonly baseUrl: string) {}

  /** LOGIN */
  async login(req: AuthRequest): Promise<AuthResponse> {
    const uri = `${this.baseUrl}/u/login`;
    const res = await fetch(uri, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify(authRequestToApi(req)),
    });

    const text = await res.text();
    const body: Json = safeJson(text);

    if (res.ok) {
      const auth = authResponseFromApi(body);
      await AsyncStorage.multiSet([
        ['auth_token', auth.token],
        ['user_email', auth.user?.email ?? ''],
        ['user_id', String(auth.user?.id ?? '')],
      ]);
      return auth;
    }

    const msg = (body && typeof body.message === 'string')
      ? body.message
      : 'Falha ao autenticar';
    throw new Error(msg);
  }

  /** CADASTRO */
  async registerUser(input: {
    username: string;
    email: string;
    password: string;
    status?: string;
  }): Promise<boolean> {
    const uri = `${this.baseUrl}/u/signup`;
    const payload: Json = {
      username: input.username.trim(),
      email: input.email.trim(),
      password: input.password,
      ...(input.status ? { status: input.status } : {}),
    };

    const res = await fetch(uri, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify(payload),
    });

    if (res.ok) return true;

    const body: Json = safeJson(await res.text());
    const msg = (body && typeof body.message === 'string')
      ? body.message
      : 'Falha ao criar conta';
    throw new Error(msg);
  }

  /** LOGOUT */
  async logout(): Promise<void> {
    await AsyncStorage.multiRemove(['auth_token', 'user_email', 'user_id']);
  }

  /** Opcional: recuperar token para interceptors */
  async getToken(): Promise<string | null> {
    return AsyncStorage.getItem('auth_token');
  }

  /** Opcional: recuperar utilizador simples do cache */
  async getCachedUser(): Promise<Pick<User, 'id' | 'email'> | null> {
    const [id, email] = await AsyncStorage.multiGet(['user_id', 'user_email']);
    const uid = id?.[1] ? Number(id[1]) : NaN;
    if (!Number.isFinite(uid) || !email?.[1]) return null;
    return { id: uid, email: email[1] } as any;
  }
}

/** Helper seguro para JSON */
function safeJson(text: string): Json {
  try {
    const v = JSON.parse(text);
    return typeof v === 'object' && v ? v : {};
  } catch {
    return {};
  }
}
