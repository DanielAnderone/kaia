// src/utils/tokenManager.ts
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { jwtDecode } from 'jwt-decode';
import { type User, userFromApi, userToApi } from '../models/model';

/* ----------------- Constantes ----------------- */
const K_TOKEN   = 'jwt_token';
const K_PAYLOAD = 'payload';     // payload decodificado OU perfil normalizado
const K_USER    = 'auth_user';   // perfil retornado pelo backend (opcional)

const BASE_URL =
  process.env.EXPO_PUBLIC_API_BASE_URL ?? 'https://kaia.loophole.site';

type AnyRec = Record<string, any>;

/* ----------------- JWT e Payload ----------------- */
async function setJWTToken(token: string): Promise<void> {
  await AsyncStorage.setItem(K_TOKEN, token);
}

async function getJWTToken(): Promise<string | null> {
  return AsyncStorage.getItem(K_TOKEN);
}

async function setPayload(user: User): Promise<void> {
  const json = JSON.stringify(userToApi(user));
  await AsyncStorage.setItem(K_PAYLOAD, json);
}

async function getPayload(): Promise<User> {
  const raw = await AsyncStorage.getItem(K_PAYLOAD);
  if (!raw) throw new Error('Payload não encontrado');
  return userFromApi(JSON.parse(raw));
}

/* ----------------- User (direto do backend) ----------------- */
async function setUser(u: AnyRec | null | undefined): Promise<void> {
  await AsyncStorage.setItem(K_USER, JSON.stringify(u ?? {}));
}

async function getUser<T = AnyRec>(): Promise<T | null> {
  const raw = await AsyncStorage.getItem(K_USER);
  return raw ? (JSON.parse(raw) as T) : null;
}

/* ----------------- Decodificação do Token ----------------- */
export async function setPayloadFromToken(token: string): Promise<AnyRec> {
  try {
    const decoded = jwtDecode<AnyRec>(token) || {};
    const normalized: User = {
      id: decoded?.sub ?? decoded?.id ?? 0,
      name: decoded?.name ?? decoded?.fullName ?? '',
      email: decoded?.email ?? '',
      role: decoded?.role ?? decoded?.perfil ?? 'user',
    } as any;

    await AsyncStorage.setItem(K_PAYLOAD, JSON.stringify(normalized));
    return normalized;
  } catch (err) {
    console.warn('Falha ao decodificar token JWT', err);
    await AsyncStorage.setItem(K_PAYLOAD, '{}');
    return {};
  }
}

/* ----------------- Limpar sessão ----------------- */
async function clear(): Promise<void> {
  await AsyncStorage.multiRemove([K_TOKEN, K_PAYLOAD, K_USER]);
}

/* ----------------- Gestor de Sessão ----------------- */
export const SesManager = {
  setJWTToken,
  getJWTToken,

  setPayload,
  getPayload,

  setPayloadFromToken, // usado logo após o login
  setUser,
  getUser,

  clear,
  delete: clear, // alias
  getBaseURL: () => BASE_URL,
};

/* ----------------- Cliente Axios ----------------- */
export const api = axios.create({
  baseURL: BASE_URL,
  timeout: 15000,
});

api.interceptors.request.use(async (config) => {
  const token = await getJWTToken();
  if (token) {
    config.headers = config.headers ?? {};
    (config.headers as Record<string, string>)['Authorization'] = `Bearer ${token}`;
  }
  return config;
});
