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
  Platform,
} from 'react-native';
import { useNavigation, StackActions, type NavigationProp } from '@react-navigation/native';
import type { RootStackParamList } from '../../App';

const PRIMARY = '#169C1D';

export enum AppTab {
  Inicio = 'Inicio',
  investments = 'investments',
  transacao = 'transacao',
  profile = 'profile',
}

type Props = { current: AppTab };

// mapeamento tipado para as rotas definidas no App.tsx
const ROUTE: Record<AppTab, keyof RootStackParamList> = {
  [AppTab.Inicio]: 'InvestorProjects',
  [AppTab.investments]: 'InvestorInvestments',
  [AppTab.transacao]: 'InvestorTransactions',
  [AppTab.profile]: 'InvestorProfile',
};

export const AppBottomNav: React.FC<Props> = ({ current }) => {
  const nav = useNavigation<NavigationProp<RootStackParamList>>();
  const isDark = useColorScheme() === 'dark';
  const [loading, setLoading] = useState(false);

  const go = (tab: AppTab) => {
    if (tab === current) return;
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      nav.dispatch(StackActions.replace(ROUTE[tab]));
    }, 250);
  };

  const ripple = Platform.select({ android: { color: '#00000010', borderless: true }, default: undefined });

  return (
    <>
      <View
        style={[
          s.container,
          { backgroundColor: isDark ? '#1F2937' : '#fff', borderTopColor: isDark ? '#374151' : '#D1D5DB' },
        ]}
      >
        <NavItem label="Início" icon="🏠" selected={current === AppTab.Inicio} onPress={() => go(AppTab.Inicio)} ripple={ripple} />
        <NavItem label="Investimentos" icon="📈" selected={current === AppTab.investments} onPress={() => go(AppTab.investments)} ripple={ripple} />
        <NavItem label="Transações" icon="🧾" selected={current === AppTab.transacao} onPress={() => go(AppTab.transacao)} ripple={ripple} />
        <NavItem label="Perfil" icon="👤" selected={current === AppTab.profile} onPress={() => go(AppTab.profile)} ripple={ripple} />
      </View>

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
  icon: string;
  selected: boolean;
  onPress: () => void;
  ripple?: any;
}> = ({ label, icon, selected, onPress, ripple }) => {
  const color = selected ? PRIMARY : '#9CA3AF';
  return (
    <Pressable android_ripple={ripple} style={s.item} onPress={onPress}>
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
  item: { flex: 1, alignItems: 'center', paddingVertical: 4, borderRadius: 9999 },
  icon: { fontSize: 20, lineHeight: 22 },
  label: { fontSize: 12, fontWeight: '600', letterSpacing: 0.15, marginTop: 2 },
  loaderBackdrop: { flex: 1, backgroundColor: 'rgba(0,0,0,0.15)', alignItems: 'center', justifyContent: 'center' },
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
