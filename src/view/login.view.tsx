// src/screens/LoginView.tsx
import React, { useMemo, useState } from 'react';
import {
  View,
  Text,
  TextInput,
  Image,
  TouchableOpacity,
  ActivityIndicator,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';

// serviços
import { AuthService } from '../service/auth.service';
import type { AuthResponse } from '../models/model';

// sessão util  (ajuste o caminho para o arquivo correto)
import { SesManager, setPayloadFromToken } from '../utils/token.management';

type Props = {
  apiBaseUrl?: string;
  logoSource?: any;      // ImageSourcePropType
  buttonColor?: string;
};

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

export const LoginView: React.FC<Props> = ({
  apiBaseUrl,
  logoSource,
  buttonColor = '#22C55E',
}) => {
  const nav = useNavigation<any>();

  // decida a base uma vez. Não acesse propriedades privadas do serviço.
  const serviceBase = apiBaseUrl ?? SesManager.getBaseURL();
  const auth = useMemo(() => new AuthService(serviceBase), [serviceBase]);

  const [email, setEmail] = useState('');
  const [pass, setPass] = useState('');
  const [obscure, setObscure] = useState(true);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const validate = () => {
    if (!email.trim()) return 'Informe o email';
    if (!EMAIL_RE.test(email.trim())) return 'Email inválido';
    if (!pass) return 'Informe a senha';
    return null;
  };

  const routeForRole = (role?: string) => {
    const r = String(role || '').toUpperCase();
    if (r === 'ADMIN') return 'AdminDashboard';
    return 'InvestorProjects';
  };

  const handleSubmit = async () => {
    const v = validate();
    if (v) {
      setErr(v);
      return;
    }
    setErr(null);
    setLoading(true);
    try {
      const res: AuthResponse = await auth.login({
        email: email.trim(),
        password: pass,
      });

      if (!res?.token) throw new Error('Token não recebido');
      await SesManager.setJWTToken(res.token);

      if (res.user) {
        await SesManager.setPayload(res.user as any);
      } else {
        await setPayloadFromToken(res.token);
      }

      const payload = await SesManager.getPayload().catch(() => null as any);
      const role = payload?.role ?? res.user?.role;

      const displayName =
        payload?.name ||
        payload?.fullName ||
        (res.user as any)?.username ||
        res.user?.email ||
        email.trim();

      nav.reset({
        index: 0,
        routes: [{ name: routeForRole(role), params: { displayName } }],
      });
    } catch (e: any) {
      setErr(e?.message || 'Falha ao autenticar');
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.select({ ios: 'padding', android: undefined })}
    >
      <View style={styles.center}>
        {logoSource ? (
          <Image source={logoSource} style={styles.logo} resizeMode="contain" />
        ) : (
          <Text style={styles.logoFallback}>◎</Text>
        )}

        <View style={styles.form}>
          {/* Email */}
          <View style={styles.underlineWrap}>
            <TextInput
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
              placeholder="Email"
              placeholderTextColor="#000"
              style={styles.input}
              returnKeyType="next"
            />
          </View>

          {/* Password */}
          <View style={[styles.underlineWrap, { marginTop: 20 }]}>
            <TextInput
              value={pass}
              onChangeText={setPass}
              secureTextEntry={obscure}
              placeholder="Senha"
              placeholderTextColor="#000"
              style={styles.input}
              returnKeyType="done"
              onSubmitEditing={handleSubmit}
            />
            <TouchableOpacity onPress={() => setObscure(v => !v)} style={styles.suffixBtn}>
              <Text style={styles.suffixTxt}>{obscure ? '👁️' : '🙈'}</Text>
            </TouchableOpacity>
          </View>

          {/* Forgot */}
          <View style={styles.right}>
            <TouchableOpacity onPress={() => nav.navigate('Forgot')}>
              <Text style={styles.linkText}>Esqueceu a senha?</Text>
            </TouchableOpacity>
          </View>

          {/* Login button */}
          <TouchableOpacity
            disabled={loading}
            onPress={handleSubmit}
            style={[styles.btn, { backgroundColor: buttonColor }]}
          >
            {loading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.btnText}>ENTRAR</Text>
            )}
          </TouchableOpacity>

          {/* Sign up */}
          <View style={styles.right}>
            <TouchableOpacity
              onPress={() =>
                nav.navigate('SignUp', {
                  apiBaseUrl: serviceBase, // NÃO usa auth.baseUrl privado
                  buttonColor,
                })
              }
            >
              <Text style={[styles.signup, { color: buttonColor }]}>CRIAR CONTA</Text>
            </TouchableOpacity>
          </View>

          {/* Error */}
          {!!err && (
            <Text style={styles.error} numberOfLines={3}>
              {err}
            </Text>
          )}
        </View>
      </View>
    </KeyboardAvoidingView>
  );
};

/* =================
 * STYLES
 * =============== */
const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 16 },
  logo: { height: 56, width: 200, marginBottom: 24 },
  logoFallback: { fontSize: 48, color: '#000', marginBottom: 24 },
  form: { width: 320, maxWidth: '92%' },
  underlineWrap: {
    borderBottomWidth: StyleSheet.hairlineWidth * 2,
    borderBottomColor: '#000',
    position: 'relative',
  },
  input: {
    height: 40,
    paddingVertical: 10,
    color: '#000',
  },
  suffixBtn: { position: 'absolute', right: 0, top: 8, height: 24, width: 40, alignItems: 'center' },
  suffixTxt: { color: '#000', fontSize: 14 },
  right: { alignItems: 'flex-end', marginTop: 10 },
  linkText: { color: '#000' },
  btn: {
    height: 48,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 10,
    elevation: 4,
    shadowColor: '#000',
  },
  btnText: { color: '#fff', fontWeight: '700' },
  signup: { fontWeight: '700', letterSpacing: 0.5, marginTop: 8 },
  error: { color: '#E53935', textAlign: 'center', marginTop: 10 },
});

export default LoginView;
