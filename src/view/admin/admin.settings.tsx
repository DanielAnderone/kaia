// src/screens/admin/AdminSettingsView.tsx
import React, { useEffect, useMemo, useState } from 'react';
import {
  View,
  Text,
  Switch,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { AdminSettings } from '@/models';
import { AdminSettingsService } from '@/services/admin-settings.service';

const AdminSettingsView: React.FC = () => {
  const nav = useNavigation<any>();
  const svc = useMemo(() => new AdminSettingsService(), []);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [pushNotifications, setPushNotifications] = useState(false);
  const [emailNotifications, setEmailNotifications] = useState(false);
  const [twoFactorEnabled, setTwoFactorEnabled] = useState(false);
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        const s = await svc.load();
        setPushNotifications(s.pushNotifications);
        setEmailNotifications(s.emailNotifications);
        setTwoFactorEnabled(s.twoFactorEnabled);
        setTheme((s.theme as 'light' | 'dark') ?? 'light');
      } catch (e: any) {
        setError(String(e?.message || e));
      } finally {
        setLoading(false);
      }
    })();
  }, [svc]);

  const persist = async (next: Partial<AdminSettings>) => {
    setSaving(true);
    try {
      await svc.save({
        pushNotifications,
        emailNotifications,
        twoFactorEnabled,
        theme,
        ...next,
      });
    } catch (e: any) {
      Alert.alert('Erro', String(e?.message || e));
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <View style={s.center}>
        <ActivityIndicator />
      </View>
    );
  }
  if (error) {
    return (
      <View style={s.center}>
        <Text>Erro: {error}</Text>
      </View>
    );
  }

  return (
    <View style={{ flex: 1 }}>
      {/* AppBar */}
      <View style={s.appbar}>
        <TouchableOpacity onPress={() => nav.navigate('AdminDashboard')}>
          <Text style={s.appbarBack}>‹</Text>
        </TouchableOpacity>
        <Text style={s.appbarTitle}>Configurações do Administrador</Text>
        <View style={{ width: 28 }} />
      </View>

      <ScrollView contentContainerStyle={{ padding: 16 }}>
        <Text style={s.h1}>Notificações</Text>
        <Row>
          <Text style={s.label}>Push Notifications</Text>
          <Switch
            value={pushNotifications}
            onValueChange={(v) => {
              setPushNotifications(v);
              persist({ pushNotifications: v });
            }}
          />
        </Row>
        <Row>
          <Text style={s.label}>Email Notifications</Text>
          <Switch
            value={emailNotifications}
            onValueChange={(v) => {
              setEmailNotifications(v);
              persist({ emailNotifications: v });
            }}
          />
        </Row>

        <View style={{ height: 16 }} />

        <Text style={s.h1}>Aparência</Text>
        <View style={{ flexDirection: 'row' }}>
          <Choice
            label="Light"
            selected={theme === 'light'}
            onPress={() => {
              setTheme('light');
              persist({ theme: 'light' });
            }}
          />
          <View style={{ width: 8 }} />
          <Choice
            label="Dark"
            selected={theme === 'dark'}
            onPress={() => {
              setTheme('dark');
              persist({ theme: 'dark' });
            }}
          />
        </View>

        <View style={{ height: 16 }} />

        <Text style={s.h1}>Segurança</Text>
        <Row>
          <View style={{ flex: 1 }}>
            <Text style={s.label}>Autenticação de Dois Fatores</Text>
            <Text style={s.sub}>Adicione uma camada extra de segurança à sua conta.</Text>
          </View>
          <Switch
            value={twoFactorEnabled}
            onValueChange={(v) => {
              setTwoFactorEnabled(v);
              persist({ twoFactorEnabled: v });
            }}
          />
        </Row>

        <View style={{ height: 24 }} />

        <TouchableOpacity
          style={[s.btn, { backgroundColor: '#111827' }]}
          onPress={async () => {
            // simulação de logout
            await new Promise((r) => setTimeout(r, 500));
            Alert.alert('Sessão', 'Logout realizado com sucesso!');
          }}
          disabled={saving}
        >
          <Text style={[s.btnTxt, { color: '#fff' }]}>{saving ? 'A guardar…' : 'Logout'}</Text>
        </TouchableOpacity>
      </ScrollView>
    </View>
  );
};

const Row: React.FC<React.PropsWithChildren> = ({ children }) => (
  <View style={s.row}>{children}</View>
);

const Choice: React.FC<{ label: string; selected: boolean; onPress: () => void }> = ({
  label,
  selected,
  onPress,
}) => (
  <TouchableOpacity
    onPress={onPress}
    style={[
      s.choice,
      { backgroundColor: selected ? '#E5F5EA' : '#F3F4F6', borderColor: selected ? '#169C1D' : '#D1D5DB' },
    ]}
  >
    <Text style={{ color: selected ? '#169C1D' : '#374151', fontWeight: '700' }}>{label}</Text>
  </TouchableOpacity>
);

const s = StyleSheet.create({
  appbar: {
    height: 56,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
    alignItems: 'center',
    flexDirection: 'row',
    paddingHorizontal: 12,
  },
  appbarBack: { color: '#111', fontSize: 22, width: 28, textAlign: 'center' },
  appbarTitle: { flex: 1, textAlign: 'center', fontWeight: '700', fontSize: 16, color: '#111' },

  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },

  h1: { fontSize: 22, fontWeight: '700', color: '#111', marginBottom: 8 },
  row: {
    paddingVertical: 10,
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  label: { color: '#111827', fontSize: 16, fontWeight: '600' },
  sub: { color: '#6B7280', fontSize: 12, marginTop: 4 },

  choice: {
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 999,
    borderWidth: 1,
  },

  btn: {
    minHeight: 50,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  btnTxt: { fontWeight: '700' },
});

export default AdminSettingsView;
