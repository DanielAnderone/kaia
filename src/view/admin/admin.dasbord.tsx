// src/screens/admin/AdminDashboardView.tsx
import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ActivityIndicator,
  useWindowDimensions,
  StyleSheet,
  Modal,
  Pressable,
  FlatList,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import type { AdminStats } from '../../models/model';

// serviço simples para buscar os cards do dashboard
type Json = Record<string, any>;
const safeJson = (t: string): Json => { try { return JSON.parse(t); } catch { return {}; } };

async function fetchStats(baseUrl = 'https://kaia.loophole.site'): Promise<AdminStats[]> {
  const res = await fetch(`${baseUrl}/admin/stats`, { headers: { Accept: 'application/json' } });
  const body = safeJson(await res.text());
  if (!res.ok) throw new Error(typeof body.message === 'string' ? body.message : 'Falha ao carregar');
  const arr: any[] = Array.isArray(body) ? body : Array.isArray(body?.data) ? body.data : [];
  return arr.map((j) => ({
    title: String(j?.title ?? ''),
    value: String(j?.value ?? ''),
    icon: String(j?.icon ?? '•'),
  }));
}

const AdminDashboardView: React.FC = () => {
  const nav = useNavigation<any>();
  const { width } = useWindowDimensions();
  const wide = width > 800;

  const [openDrawer, setOpenDrawer] = React.useState(false);
  const [state, setState] = React.useState<{loading: boolean; data: AdminStats[]; error?: string}>({
    loading: true, data: [],
  });

  React.useEffect(() => {
    let m = true;
    (async () => {
      try {
        const data = await fetchStats();
        if (m) setState({ loading: false, data });
      } catch (e: any) {
        if (m) setState({ loading: false, data: [], error: String(e?.message || e) });
      }
    })();
    return () => { m = false; };
  }, []);

  if (state.loading) {
    return (
      <View style={[s.fill, s.center]}>
        <ActivityIndicator />
      </View>
    );
  }

  return (
    <View style={s.fill}>
      {/* AppBar somente em telas estreitas */}
      {!wide && (
        <View style={[s.appbar]}>
          <TouchableOpacity onPress={() => setOpenDrawer(true)}>
            <Text style={s.appbarIcon}>☰</Text>
          </TouchableOpacity>
          <Text style={s.appbarTitle}>Painel Administrativo</Text>
          <TouchableOpacity onPress={() => nav.navigate('AdminProfile')}>
            <Text style={s.appbarIcon}>👤</Text>
          </TouchableOpacity>
        </View>
      )}

      <View style={{ flex: 1, flexDirection: 'row' }}>
        {/* Sidebar fixa para wide */}
        {wide && <Sidebar onNavigate={(r) => nav.navigate(r)} />}

        {/* Conteúdo */}
        <View style={{ flex: 1 }}>
          {/* Cabeçalho em wide */}
          {wide && (
            <View style={s.headerRow}>
              <Text style={s.headerTitle}>Painel Administrativo</Text>
              <TouchableOpacity onPress={() => nav.navigate('AdminProfile')}>
                <View style={s.avatar}><Text>👤</Text></View>
              </TouchableOpacity>
            </View>
          )}

          <FlatList
            ListHeaderComponent={<Text style={s.sectionTitle}>Visão geral</Text>}
            data={state.data}
            keyExtractor={(_, i) => String(i)}
            contentContainerStyle={{ padding: 24, paddingTop: 8 }}
            numColumns={wide ? 4 : 2}
            columnWrapperStyle={{ justifyContent: 'space-between', marginBottom: 16 }}
            renderItem={({ item }) => <StatCard stat={item} />}
            ListFooterComponent={<QuickActions onNavigate={(r) => nav.navigate(r)} />}
          />
        </View>
      </View>

      {/* Drawer para telas estreitas */}
      <Modal visible={openDrawer} transparent animationType="slide" onRequestClose={() => setOpenDrawer(false)}>
        <Pressable style={s.drawerBackdrop} onPress={() => setOpenDrawer(false)} />
        <View style={s.drawer}>
          <View style={s.drawerHeader}>
            <Text style={s.brandIcon}>🥚</Text>
            <Text style={s.brandTitle}>Kaia Invest</Text>
          </View>
          <DrawerItem label="Painel" selected onPress={() => setOpenDrawer(false)} />
          <DrawerItem label="Investidores" onPress={() => { setOpenDrawer(false); nav.navigate('AdminInvestors'); }} />
          <DrawerItem label="Projetos de Investimento" onPress={() => { setOpenDrawer(false); nav.navigate('AdminProjectManagement'); }} />
          <DrawerItem label="Configurações" onPress={() => { setOpenDrawer(false); nav.navigate('AdminSettings'); }} />
          <View style={{ flex: 1 }} />
          <DrawerItem label="Sair" onPress={() => { setOpenDrawer(false); nav.reset({ index: 0, routes: [{ name: 'Login' }] }); }} />
        </View>
      </Modal>
    </View>
  );
};

/* ========= componentes ========= */

const Sidebar: React.FC<{ onNavigate: (route: string) => void }> = ({ onNavigate }) => {
  return (
    <View style={s.sidebar}>
      <View style={s.brandRow}>
        <Text style={s.brandIcon}>🥚</Text>
        <Text style={s.brandTitle}>Kaia Invest</Text>
      </View>
      <SidebarButton label="Painel" selected />
      <SidebarButton label="Investidores" onPress={() => onNavigate('AdminInvestors')} />
      <SidebarButton label="Projetos de Investimento" onPress={() => onNavigate('AdminProjectManagement')} />
      <SidebarButton label="Configurações" onPress={() => onNavigate('AdminSettings')} />
      <View style={{ flex: 1 }} />
      <SidebarButton label="Sair" onPress={() => onNavigate('Login')} />
    </View>
  );
};

const SidebarButton: React.FC<{ label: string; selected?: boolean; onPress?: () => void }> = ({
  label, selected, onPress,
}) => (
  <TouchableOpacity onPress={onPress} disabled={selected} style={s.sidebarBtn}>
    <Text style={[s.sidebarBtnTxt, selected ? s.sidebarBtnTxtSel : null]}>{label}</Text>
  </TouchableOpacity>
);

const DrawerItem: React.FC<{ label: string; selected?: boolean; onPress?: () => void }> = ({
  label, selected, onPress,
}) => (
  <TouchableOpacity onPress={onPress} style={s.drawerItem}>
    <Text style={[s.drawerTxt, selected ? s.drawerTxtSel : null]}>{label}</Text>
  </TouchableOpacity>
);

const StatCard: React.FC<{ stat: AdminStats }> = ({ stat }) => (
  <View style={s.statCard}>
    <Text style={s.statIcon}>{stat.icon || '•'}</Text>
    <Text style={s.statTitle} numberOfLines={1}>{stat.title}</Text>
    <Text style={s.statValue} numberOfLines={1}>{stat.value}</Text>
  </View>
);

const QuickActions: React.FC<{ onNavigate: (r: string) => void }> = ({ onNavigate }) => {
  const items = [
    { label: 'Ver Investidores', route: 'AdminInvestors' },
    { label: 'Adicionar Projeto', route: 'AdminProjectManagement' },
    { label: 'Gestão de investimentos', route: 'AdminInvestments' },
  ];
  return (
    <View>
      <Text style={s.sectionTitle}>Ações Rápidas</Text>
      {items.map((b, i) => (
        <TouchableOpacity key={i} onPress={() => onNavigate(b.route)} style={s.qaBtn}>
          <Text style={s.qaTxt}>{b.label}</Text>
        </TouchableOpacity>
      ))}
    </View>
  );
};

/* ========= estilos ========= */

const primary = '#386641';

const s = StyleSheet.create({
  fill: { flex: 1, backgroundColor: '#F5F5F5' },
  center: { alignItems: 'center', justifyContent: 'center' },

  appbar: {
    height: 56,
    backgroundColor: primary,
    paddingHorizontal: 12,
    flexDirection: 'row',
    alignItems: 'center',
  },
  appbarIcon: { color: '#fff', fontSize: 20, width: 28, textAlign: 'center' },
  appbarTitle: { color: '#fff', fontWeight: '700', fontSize: 18, flex: 1, textAlign: 'center' },

  headerRow: {
    paddingHorizontal: 24, paddingTop: 24, paddingBottom: 8,
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
  },
  headerTitle: { fontSize: 22, fontWeight: '700', color: '#111' },
  avatar: { width: 36, height: 36, borderRadius: 18, backgroundColor: '#fff', alignItems: 'center', justifyContent: 'center' },

  sidebar: { width: 240, backgroundColor: '#fff', padding: 16, borderRightWidth: 1, borderRightColor: '#E5E7EB' },
  brandRow: { flexDirection: 'row', alignItems: 'center' },
  brandIcon: { fontSize: 26 },
  brandTitle: { fontSize: 20, fontWeight: '700', marginLeft: 8 },
  sidebarBtn: { paddingVertical: 10, paddingHorizontal: 8, borderRadius: 8, marginTop: 8 },
  sidebarBtnTxt: { color: '#4B5563', fontWeight: '600' },
  sidebarBtnTxtSel: { color: primary },

  drawerBackdrop: { flex: 1, backgroundColor: 'rgba(0,0,0,0.25)' },
  drawer: {
    position: 'absolute', top: 0, bottom: 0, left: 0, width: 280,
    backgroundColor: '#fff', paddingTop: 40, paddingHorizontal: 16,
  },
  drawerHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 16 },
  drawerItem: { paddingVertical: 12 },
  drawerTxt: { color: '#4B5563', fontWeight: '600' },
  drawerTxtSel: { color: primary },

  sectionTitle: { fontSize: 18, fontWeight: '700', color: '#111', marginTop: 8, marginBottom: 12 },

  statCard: {
    width: '48%', backgroundColor: '#fff', borderRadius: 16, padding: 16,
    borderWidth: 1, borderColor: '#E5E7EB',
  },
  statIcon: { fontSize: 22, color: '#F2C46D', marginBottom: 8 },
  statTitle: { fontSize: 13, color: '#6B7280' },
  statValue: { fontSize: 22, fontWeight: '700', marginTop: 4 },

  qaBtn: {
    width: '100%', backgroundColor: primary, borderRadius: 12, paddingVertical: 14,
    alignItems: 'center', justifyContent: 'center', marginBottom: 12,
  },
  qaTxt: { color: '#fff', fontWeight: '700' },
});

export default AdminDashboardView;
