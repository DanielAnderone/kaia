// src/utils/tokenManager.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import { type User, userFromApi, userToApi } from '../models/model';

const K_TOKEN = 'jwt_token';
const K_PAYLOAD = 'payload';

const setPayload = async (user: User): Promise<void> => {
  try {
    const json = JSON.stringify(userToApi(user));
    await AsyncStorage.setItem(K_PAYLOAD, json);
  } catch (e: any) {
    throw new Error(`Erro ao salvar payload: ${String(e?.message || e)}`);
  }
};

const getPayload = async (): Promise<User> => {
  try {
    const raw = await AsyncStorage.getItem(K_PAYLOAD);
    if (!raw) throw new Error('Payload não encontrado');
    const obj = JSON.parse(raw);
    return userFromApi(obj);
  } catch (e: any) {
    throw new Error(`Erro ao recuperar payload: ${String(e?.message || e)}`);
  }
};

const setJWTToken = async (token: string): Promise<void> => {
  try {
    await AsyncStorage.setItem(K_TOKEN, token);
  } catch (e: any) {
    throw new Error(`Erro ao salvar token: ${String(e?.message || e)}`);
  }
};

const getJWTToken = async (): Promise<string | null> => {
  try {
    return await AsyncStorage.getItem(K_TOKEN);
  } catch (e: any) {
    throw new Error(`Erro ao recuperar token: ${String(e?.message || e)}`);
  }
};

const clear = async (): Promise<void> => {
  try {
    await AsyncStorage.multiRemove([K_TOKEN, K_PAYLOAD]);
  } catch (e: any) {
    throw new Error(`Erro ao deletar dados: ${String(e?.message || e)}`);
  }
};

export const SesManager = {
  setPayload,
  getPayload,
  setJWTToken,
  getJWTToken,
  delete: clear,
};
