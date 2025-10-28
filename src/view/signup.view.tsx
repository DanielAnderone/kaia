// src/screens/SignUpView.tsx
import React, { useMemo, useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ActivityIndicator,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  Alert,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { AuthService } from '../service/auth.service';

type Props = {
  apiBaseUrl?: string;            // padrão igual ao Flutter
  buttonColor?: string;           // cor do botão
};

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

const SignUpView: React.FC<Props> = ({
  apiBaseUrl = 'https://kaia.loophole.site',
  buttonColor = '#22C55E',
}) => {
  const nav = useNavigation<any>();
  const auth = useMemo(() => new AuthService(apiBaseUrl), [apiBaseUrl]);

  const [nome, setNome] = useState('');
  const [email, setEmail] = useState('');
  const [telefone, setTelefone] = useState('');
  const [senha, setSenha] = useState('');
  const [confirmar, setConfirmar] = useState('');
  const [ob1, setOb1] = useState(true);
  const [ob2, setOb2] = useState(true);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const validate = () => {
    if (!nome.trim()) return 'Informe o nome de usuário';
    if (!email.trim()) return 'Informe o email';
    if (!EMAIL_RE.test(email.trim())) return 'Email inválido';
    if (senha.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
    if (!confirmar) return 'Confirme a senha';
    if (senha !== confirmar) return 'As senhas não coincidem';
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
      await auth.registerUser({
        username: nome,
        email,
        password: senha,
        // status: 'active',
      });

      Alert.alert('Sucesso', 'Conta criada com sucesso!');
      // volta ao Login, como no Flutter:
      nav.reset({
        index: 0,
        routes: [{ name: 'Login', params: { fromSignup: true, prefillEmail: email } }],
      });
    } catch (e: any) {
      setErr(e?.message || 'Falha ao criar conta');
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={s.container}
      behavior={Platform.select({ ios: 'padding', android: undefined })}
    >
      <View style={s.center}>
        <Text style={s.headerIcon}>➕</Text>

        <View style={s.form}>
          <View style={s.underlineWrap}>
            <TextInput
              value={nome}
              onChangeText={setNome}
              placeholder="Nome de usuário"
              placeholderTextColor="#000"
              style={s.input}
              autoCapitalize="none"
              autoCorrect={false}
              returnKeyType="next"
            />
          </View>

          <View style={[s.underlineWrap, { marginTop: 18 }]}>
            <TextInput
              value={email}
              onChangeText={setEmail}
              placeholder="Email"
              placeholderTextColor="#000"
              style={s.input}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
              returnKeyType="next"
            />
          </View>

          <View style={[s.underlineWrap, { marginTop: 18 }]}>
            <TextInput
              value={telefone}
              onChangeText={setTelefone}
              placeholder="Telefone (opcional)"
              placeholderTextColor="#000"
              style={s.input}
              keyboardType="phone-pad"
              returnKeyType="next"
            />
          </View>

          <View style={[s.underlineWrap, { marginTop: 18 }]}>
            <TextInput
              value={senha}
              onChangeText={setSenha}
              placeholder="Senha"
              placeholderTextColor="#000"
              style={s.input}
              secureTextEntry={ob1}
              returnKeyType="next"
            />
            <TouchableOpacity onPress={() => setOb1(v => !v)} style={s.suffixBtn}>
              <Text style={s.suffixTxt}>{ob1 ? '👁️' : '🙈'}</Text>
            </TouchableOpacity>
          </View>

          <View style={[s.underlineWrap, { marginTop: 18 }]}>
            <TextInput
              value={confirmar}
              onChangeText={setConfirmar}
              placeholder="Confirmar senha"
              placeholderTextColor="#000"
              style={s.input}
              secureTextEntry={ob2}
              returnKeyType="done"
            />
            <TouchableOpacity onPress={() => setOb2(v => !v)} style={s.suffixBtn}>
              <Text style={s.suffixTxt}>{ob2 ? '👁️' : '🙈'}</Text>
            </TouchableOpacity>
          </View>

          <TouchableOpacity
            disabled={loading}
            onPress={handleSubmit}
            style={[s.btn, { backgroundColor: buttonColor, marginTop: 20 }]}
          >
            {loading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={s.btnText}>CRIAR CONTA</Text>
            )}
          </TouchableOpacity>

          <View style={s.right}>
            <TouchableOpacity
              onPress={() =>
                nav.reset({
                  index: 0,
                  routes: [{ name: 'Login', params: { prefillEmail: email } }],
                })
              }
            >
              <Text style={[s.signup, { color: buttonColor }]}>
                Já tem conta? Entrar
              </Text>
            </TouchableOpacity>
          </View>

          {!!err && <Text style={s.error}>{err}</Text>}
        </View>
      </View>
    </KeyboardAvoidingView>
  );
};

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 16 },
  headerIcon: { fontSize: 48, color: '#000', marginBottom: 24 },
  form: { width: 320 },
  underlineWrap: {
    borderBottomWidth: StyleSheet.hairlineWidth * 2,
    borderBottomColor: '#000',
    position: 'relative',
  },
  input: { height: 40, paddingVertical: 10, color: '#000' },
  suffixBtn: { position: 'absolute', right: 0, top: 8, height: 24, width: 40, alignItems: 'center' },
  suffixTxt: { color: '#000', fontSize: 14 },
  btn: {
    height: 48,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 4,
    shadowColor: '#000',
  },
  btnText: { color: '#fff', fontWeight: '700' },
  right: { alignItems: 'flex-end', marginTop: 8 },
  signup: { fontWeight: '700', letterSpacing: 0.5, marginTop: 8 },
  error: { color: '#E53935', textAlign: 'center', marginTop: 10 },
});

export default SignUpView;
