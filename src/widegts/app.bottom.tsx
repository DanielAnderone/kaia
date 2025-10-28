// src/widgets/AppBottomNav.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  Pressable,
  Modal,
  ActivityIndicator,
  StyleSheet,
  useColorScheme,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../../App';

const PRIMARY = '#169C1D';

export enum AppTab {
  Inicio = 'Inicio',
  investments = 'investments',
  transacao = 'transacao',
  profile = 'profile',
}

type Props = { current: AppTab };

export const AppBottomNav: React.FC<Props> = ({ current }) => {
  const nav = useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  const isDark = useColorScheme() === 'dark';
  const [loading, setLoading] = useState(false);

  const go = (tab: AppTab) => {
    if (tab === current) return;

    const route =
      tab === AppTab.Inicio
        ? 'InvestorProjects'
        : tab === AppTab.investments
        ? 'InvestorInvestments'
        : tab === AppTab.transacao
        ? 'InvestorTransactions'
        : 'InvestorProfile';

    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      // equivalente a pushReplacementNamed
      nav.replace(route as keyof RootStackParamList);
    }, 250);
  };

  return (
    <>
      <View
        style={[
          s.container,
          { backgroundColor: isDark ? '#1F2937' : '#fff', borderTopColor: isDark ? '#374151' : '#D1D5DB' },
        ]}
      >
        <NavItem
          label="Início"
          icon="🏠"
          selected={current === AppTab.Inicio}
          onPress={() => go(AppTab.Inicio)}
        />
        <NavItem
          label="Investimentos"
          icon="📈"
          selected={current === AppTab.investments}
          onPress={() => go(AppTab.investments)}
        />
        <NavItem
          label="Transações"
          icon="🧾"
          selected={current === AppTab.transacao}
          onPress={() => go(AppTab.transacao)}
        />
        <NavItem
          label="Perfil"
          icon="👤"
          selected={current === AppTab.profile}
          onPress={() => go(AppTab.profile)}
        />
      </View>

      {/* Loader compacto */}
      <Modal visible={loading} transparent animationType="fade" statusBarTranslucent>
        <View style={s.loaderBackdrop}>
          <View style={s.loaderBox}>
            <ActivityIndicator size="small" color="#fff" />
          </View>
        </View>
      </Modal>
    </>
  );
};

const NavItem: React.FC<{
  label: string;
  icon: string; // usando emoji para evitar dependências
  selected: boolean;
  onPress: () => void;
}> = ({ label, icon, selected, onPress }) => {
  const color = selected ? PRIMARY : '#9CA3AF';
  return (
    <Pressable
      android_ripple={{ color: '#00000010', borderless: true }}
      style={s.item}
      onPress={onPress}
    >
      <Text style={[s.icon, { color }]}>{icon}</Text>
      <Text style={[s.label, { color }]}>{label}</Text>
    </Pressable>
  );
};

const s = StyleSheet.create({
  container: {
    paddingHorizontal: 16,
    paddingTop: 8,
    paddingBottom: 10,
    borderTopWidth: StyleSheet.hairlineWidth,
    flexDirection: 'row',
  },
  item: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 4,
    borderRadius: 9999,
  },
  icon: { fontSize: 20, lineHeight: 22 },
  label: { fontSize: 12, fontWeight: '600', letterSpacing: 0.15, marginTop: 2 },
  loaderBackdrop: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.15)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  loaderBox: {
    width: 88,
    height: 88,
    backgroundColor: 'rgba(0,0,0,0.6)',
    borderRadius: 22,
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 6,
  },
});

export default AppBottomNav;
