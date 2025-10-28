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
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useNavigation } from '@react-navigation/native';

// ajuste estes imports se não usa alias "@"
import { AuthService } from '../service/auth.service';
import type { AuthResponse } from '../models/model';

type Props = {
  apiBaseUrl?: string;                 // padrão igual ao Flutter
  logoSource?: any;                    // ImageSourcePropType
  buttonColor?: string;                // cor do botão
};

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

export const LoginView: React.FC<Props> = ({
  apiBaseUrl = 'https://kaia.loophole.site',
  logoSource,
  buttonColor = '#22C55E',
}) => {
  const nav = useNavigation<any>();
  const auth = useMemo(() => new AuthService(apiBaseUrl), [apiBaseUrl]);

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

  const handleSubmit = async () => {
    const v = validate();
    if (v) {
      setErr(v);
      return;
    }
    setErr(null);
    setLoading(true);
    try {
      const res: AuthResponse = await auth.login({ email: email.trim(), password: pass });
      // persistência estilo SesManager
      await AsyncStorage.multiSet([
        ['auth_token', res.token],
        ['user_email', res.user.email],
        ['user_id', String(res.user.id)],
      ]);

      // navegação por role
      const role = res.user.role;
      if (role === 'admin') {
        nav.reset({ index: 0, routes: [{ name: 'AdminDashboard' }] });
      } else if (role === 'user') {
        nav.reset({ index: 0, routes: [{ name: 'InvestorProjects' }] });
      } else {
        // fallback
        nav.reset({ index: 0, routes: [{ name: 'Home' }] });
      }
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
              placeholder="Username"
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
              placeholder="Password"
              placeholderTextColor="#000"
              style={styles.input}
              returnKeyType="done"
            />
            <TouchableOpacity onPress={() => setObscure(v => !v)} style={styles.suffixBtn}>
              <Text style={styles.suffixTxt}>{obscure ? '👁️' : '🙈'}</Text>
            </TouchableOpacity>
          </View>

          {/* Forgot */}
          <View style={styles.right}>
            <TouchableOpacity onPress={() => nav.navigate('Forgot')}>
              <Text style={styles.linkText}>Forgot your password ?</Text>
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
              <Text style={styles.btnText}>LOGIN</Text>
            )}
          </TouchableOpacity>

          {/* Sign up */}
          <View style={styles.right}>
            <TouchableOpacity onPress={() => nav.navigate('SignUp', { apiBaseUrl, buttonColor })}>
              <Text style={[styles.signup, { color: buttonColor }]}>SIGN UP</Text>
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
  form: { width: 320 },
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
