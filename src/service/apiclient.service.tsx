// src/service/apiclient.service.ts
import axios from 'axios';
import Constants from 'expo-constants';

const BASE =
  process.env.EXPO_PUBLIC_API_BASE_URL ??
  (Constants.expoConfig?.extra as any)?.API_BASE_URL ??
  'https://kaia.loophole.site';

export const api = axios.create({
  baseURL: BASE,
  timeout: 15000,
});

export function setAuthToken(token?: string) {
  if (token) api.defaults.headers.common.Authorization = `Bearer ${token}`;
  else delete api.defaults.headers.common.Authorization;
}

export default api;
