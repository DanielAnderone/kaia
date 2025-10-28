// src/screens/investor/AccountView.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  Image,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  useColorScheme,
  Switch,
  Alert,
} from 'react-native';
import { AppBottomNav, AppTab } from '../../widegts/app.bottom';

type Props = {
  name?: string;
  email?: string;
  avatarUrl?: string;
};

const primary = '#169C1D';
const bgLight = '#F6F8F6';
const bgDark = '#112112';

const AccountView: React.FC<Props> = ({
  name = 'Alex Johnson',
  email = 'alex.johnson@example.com',
  avatarUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBVEcSLW51nIIxWAj1GawkdnHeKrtUgql_j7zYJDGnr-2Tt_lVBvs4-y8PKDDWUtzMZ1OZih2yy8M-nwcnOKmnK4CMCub1I60NBsBagyFBcB4E9v7Z1qg4s5YIx05kCajRhXAgNfLweJasmmQLNWWxH_9LSfPco39ZZgfocq36jI0VJ1PlCZ68fXX6WDRV5Rd6tWlBIc3vh3gSlHZkhSvzCVXCH8jrJnRoojQvYCTiBgjeHz2fICIcRY07QZT8h8OxzzBRTmkMFnnUc',
}) => {
  const isDark = useColorScheme() === 'dark';
  const [syncOn, setSyncOn] = useState(true);

  const notImpl = (msg = 'Ação não implementada') => Alert.alert('Info', msg);

  return (
    <View style={{ flex: 1, backgroundColor: isDark ? bgDark : bgLight }}>
      <View style={[s.appbar, { backgroundColor: isDark ? bgDark : bgLight }]}>
        <Text style={[s.appbarTitle, { color: isDark ? '#fff' : '#111' }]}>Conta</Text>
      </View>

      <ScrollView contentContainerStyle={{ padding: 16, paddingBottom: 24 }}>
        {/* Header */}
        <View style={[s.card, { backgroundColor: isDark ? '#2D3748' : '#fff' }]}>
          <Image
            source={{ uri: avatarUrl }}
            style={s.avatar}
            defaultSource={undefined}
          />
          <View style={{ height: 10 }} />
          <Text style={[s.name, { color: isDark ? '#fff' : '#111' }]}>{name}</Text>
          <View style={{ height: 2 }} />
          <Text style={{ color: isDark ? '#D1D5DB' : '#6B7280' }}>{email}</Text>
          <View style={{ height: 12 }} />
          <TouchableOpacity style={s.primaryBtn} onPress={() => notImpl()}>
            <Text style={s.primaryBtnTxt}>Editar perfil</Text>
          </TouchableOpacity>
        </View>

        <View style={{ height: 16 }} />
        <SectionLabel text="Segurança" dark={isDark} />
        <View style={{ height: 8 }} />
        <Tile
          dark={isDark}
          icon="🔒"
          label="Alterar palavra-passe"
          onPress={() => notImpl()}
        />

        <View style={{ height: 16 }} />
        <SectionLabel text="Dados e Pagamento" dark={isDark} />
        <View style={{ height: 8 }} />
        <Tile dark={isDark} icon="💳" label="Métodos de pagamento" onPress={() => notImpl()} />
        <SwitchTile
          dark={isDark}
          icon="☁️"
          label="Sincronização de dados"
          value={syncOn}
          onChange={setSyncOn}
        />

        <View style={{ height: 16 }} />
        <SectionLabel text="Ações da conta" dark={isDark} />
        <View style={{ height: 8 }} />
        <OutlinedBtn text="Terminar sessão" onPress={() => notImpl()} />
        <View style={{ height: 10 }} />
        <DangerBtn text="Eliminar conta" onPress={() => notImpl()} />
      </ScrollView>

      <AppBottomNav current={AppTab.profile} />
    </View>
  );
};

/* ===== subcomponentes ===== */
const SectionLabel: React.FC<{ text: string; dark: boolean }> = ({ text, dark }) => (
  <Text style={{ color: dark ? '#9CA3AF' : '#6B7280', fontSize: 12, fontWeight: '700', letterSpacing: 0.6 }}>
    {text.toUpperCase()}
  </Text>
);

const Tile: React.FC<{ dark: boolean; icon: string; label: string; onPress: () => void }> = ({
  dark, icon, label, onPress,
}) => (
  <TouchableOpacity
    onPress={onPress}
    style={[s.tile, { backgroundColor: dark ? '#2D3748' : '#fff' }]}
  >
    <View style={s.tileIconWrap}>
      <Text style={{ color: primary, fontSize: 18 }}>{icon}</Text>
    </View>
    <Text style={[s.tileText, { color: dark ? '#fff' : '#111' }]}>{label}</Text>
    <Text style={{ color: dark ? '#9CA3AF' : '#737373' }}>{'›'}</Text>
  </TouchableOpacity>
);

const SwitchTile: React.FC<{
  dark: boolean; icon: string; label: string; value: boolean; onChange: (v: boolean) => void;
}> = ({ dark, icon, label, value, onChange }) => (
  <View style={[s.tile, { backgroundColor: dark ? '#2D3748' : '#fff' }]}>
    <View style={s.tileIconWrap}>
      <Text style={{ color: primary, fontSize: 18 }}>{icon}</Text>
    </View>
    <Text style={[s.tileText, { color: dark ? '#fff' : '#111' }]}>{label}</Text>
    <Switch
      value={value}
      onValueChange={onChange}
      thumbColor="#fff"
      trackColor={{ false: '#C7CCD1', true: primary }}
    />
  </View>
);

const OutlinedBtn: React.FC<{ text: string; onPress: () => void }> = ({ text, onPress }) => (
  <TouchableOpacity onPress={onPress} style={s.outlinedBtn}>
    <Text style={[s.outlinedTxt]}>{text}</Text>
  </TouchableOpacity>
);

const DangerBtn: React.FC<{ text: string; onPress: () => void }> = ({ text, onPress }) => (
  <TouchableOpacity onPress={onPress} style={s.dangerBtn}>
    <Text style={s.dangerTxt}>{text}</Text>
  </TouchableOpacity>
);

/* ===== styles ===== */
const s = StyleSheet.create({
  appbar: { height: 56, alignItems: 'center', justifyContent: 'center' },
  appbarTitle: { fontWeight: '800', fontSize: 16 },
  card: { borderRadius: 12, padding: 16 },
  avatar: { width: 84, height: 84, borderRadius: 84, alignSelf: 'center', backgroundColor: '#E5E7EB' },
  name: { fontSize: 20, fontWeight: '800', textAlign: 'center' },
  primaryBtn: {
    height: 40,
    backgroundColor: primary,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primaryBtnTxt: { color: '#fff', fontWeight: '700' },

  tile: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 12,
    paddingHorizontal: 12,
    paddingVertical: 10,
    marginBottom: 8,
  },
  tileIconWrap: {
    width: 40, height: 40, borderRadius: 10,
    backgroundColor: '#E7F5EA', alignItems: 'center', justifyContent: 'center',
    marginRight: 12,
  },
  tileText: { flex: 1, fontSize: 15 },

  outlinedBtn: {
    height: 48, borderRadius: 10, borderWidth: 1, borderColor: primary,
    alignItems: 'center', justifyContent: 'center', backgroundColor: 'transparent',
  },
  outlinedTxt: { color: primary, fontWeight: '700' },

  dangerBtn: { height: 48, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  dangerTxt: { color: '#DC2626', fontWeight: '700' },
});

export default AccountView;
