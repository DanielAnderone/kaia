// src/screens/investor/ProjectsView.tsx
import React, { useMemo, useState } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  useColorScheme,
  useWindowDimensions,
  Alert,
  Modal,
  Pressable,
  StyleSheet,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';

// ajuste caminhos
import type { Project } from '../../models/model';
import { ProjectService } from '../../service/project.service';
import NetImage from '../../widegts/netImage';
import { AppBottomNav, AppTab } from '../../widegts/app.bottom';
import { projectImageUrl } from '../../models/model';

const primary = '#169C1D';
const bgLight = '#F6F8F6';
const bgDark = '#112112';

const ProjectsView: React.FC = () => {
  const isDark = useColorScheme() === 'dark';
  const { width } = useWindowDimensions();
  const nav = useNavigation<any>();
  const service = useMemo(() => new ProjectService(), []);

  const projCols = Math.max(2, Math.min(3, Math.floor(width / 180)));

  const [state, setState] = useState<
    { status: 'idle' | 'loading' | 'done' | 'error'; data: Project[]; error?: string }
  >({ status: 'loading', data: [] });

  const [notifOpen, setNotifOpen] = useState(false);

  React.useEffect(() => {
    let mounted = true;
    const run = async () => {
      setState(s => ({ ...s, status: 'loading' }));
      try {
        const list = await service.listProjects();
        if (!mounted) return;
        setState({ status: 'done', data: list });
      } catch (e: any) {
        if (!mounted) return;
        setState({ status: 'error', data: [], error: String(e?.message || e) });
      }
    };
    run();
    return () => { mounted = false; };
  }, [service]);

  const retry = () => {
    setState({ status: 'loading', data: [] });
    service.listProjects()
      .then(list => setState({ status: 'done', data: list }))
      .catch(e => setState({ status: 'error', data: [], error: String(e?.message || e) }));
  };

  const header = (
    <View style={{ backgroundColor: isDark ? bgDark : bgLight }}>
      <View style={{ paddingHorizontal: 16, paddingTop: 12, paddingBottom: 8, flexDirection: 'row', alignItems: 'center' }}>
        <TouchableOpacity onPress={() => showMockProfile()}>
          <View style={{ width: 40, height: 40, borderRadius: 20, overflow: 'hidden' }}>
            <NetImage url={'https://picsum.photos/seed/login-mock/80/80'} width={40} height={40} fit="cover" />
          </View>
        </TouchableOpacity>
        <View style={{ width: 8 }} />
        <Text style={{ color: isDark ? '#fff' : '#111', fontSize: 18, fontWeight: '700', flex: 1 }}>Olá</Text>
        <TouchableOpacity onPress={() => setNotifOpen(true)}>
          <Text style={{ color: isDark ? '#fff' : '#111', fontSize: 18 }}>🔔</Text>
        </TouchableOpacity>
      </View>
      <View style={{ paddingHorizontal: 16, paddingTop: 12, paddingBottom: 8 }}>
        <Text style={{ color: isDark ? '#fff' : '#111', fontSize: 22, fontWeight: '700' }}>Projetos</Text>
      </View>
    </View>
  );

  if (state.status === 'loading') {
    return (
      <View style={[s.fill, { backgroundColor: bgLight, alignItems: 'center', justifyContent: 'center' }]}>
        <ActivityIndicator />
        <AppBottomNav current={AppTab.Inicio} />
      </View>
    );
  }

  if (state.status === 'error') {
    return (
      <View style={[s.fill, { backgroundColor: bgLight, alignItems: 'center', justifyContent: 'center', padding: 16 }]}>
        <Text>Erro ao carregar projetos</Text>
        <View style={{ height: 8 }} />
        <TouchableOpacity onPress={retry} style={s.retryBtn}>
          <Text style={{ color: '#fff', fontWeight: '700' }}>Tentar novamente</Text>
        </TouchableOpacity>
        <AppBottomNav current={AppTab.Inicio} />
      </View>
    );
  }

  return (
    <View style={[s.fill, { backgroundColor: bgLight }]}>
      <FlatList
        ListHeaderComponent={header}
        data={state.data}
        key={projCols}               // força recomposição ao mudar colunas
        numColumns={projCols}
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 64 }}
        columnWrapperStyle={projCols > 1 ? { justifyContent: 'space-between' } : undefined}
        keyExtractor={(item, idx) => String(item.id ?? idx)}
        renderItem={({ item }) => (
          <ProjectCard
            project={item}
            onOpen={() => nav.navigate('ProjectDetails', { project: item })}
          />
        )}
      />

      <AppBottomNav current={AppTab.Inicio} />

      {/* Notificações (mock) */}
      <Modal visible={notifOpen} transparent animationType="slide" onRequestClose={() => setNotifOpen(false)}>
        <Pressable style={s.sheetBackdrop} onPress={() => setNotifOpen(false)} />
        <View style={s.sheet}>
          <View style={s.grabber} />
          <Text style={{ fontWeight: '800', fontSize: 16, textAlign: 'center' }}>Notificações (mock)</Text>
          <View style={{ height: 8 }} />
          {[
            { t: 'Pagamento aprovado', b: 'Seu investimento #103 foi confirmado.' },
            { t: 'Projeto atualizado', b: 'Golden Egg Farms publicou um novo relatório.' },
            { t: 'Depósito recebido', b: 'Depósito MT 2.500 creditado.' },
          ].map((n, i) => (
            <View key={i} style={s.notifRow}>
              <View style={s.notifIcon}><Text style={{ color: primary }}>🔔</Text></View>
              <View style={{ flex: 1 }}>
                <Text style={{ fontWeight: '700' }}>{n.t}</Text>
                <Text>{n.b}</Text>
              </View>
              <Text style={{ color: '#6B7280', fontSize: 12 }}>agora</Text>
            </View>
          ))}
        </View>
      </Modal>
    </View>
  );
};

const ProjectCard: React.FC<{ project: Project; onOpen: () => void }> = ({ project, onOpen }) => {
  const isDark = useColorScheme() === 'dark';
  const textPrimary = isDark ? '#fff' : '#111827';
  const textSecondary = isDark ? '#D1D5DB' : '#111827';

  const img = projectImageUrl(project as any) ?? '';

  return (
    <View style={s.card}>
      <View style={{ borderTopLeftRadius: 12, borderTopRightRadius: 12, overflow: 'hidden', aspectRatio: 16 / 10 }}>
        <NetImage url={img} fit="cover" style={{ width: '100%', height: '100%' }} />
      </View>

      <View style={{ flex: 1, paddingHorizontal: 10, paddingTop: 6, paddingBottom: 8 }}>
        <Text numberOfLines={2} style={{ color: textPrimary, fontSize: 12.5, fontWeight: '700' }}>
          {project.description ?? 'Sem nome'}
        </Text>
        <View style={{ height: 4 }} />
        <Text style={{ color: textSecondary, fontSize: 11 }}>
          Mín. investimento: MT {(project.minimumInvestment ?? 0).toFixed(0)}
        </Text>
        <Text style={{ color: textSecondary, fontSize: 11 }}>
          Rentabilidade: {(project.profitabilityPercent ?? 0).toFixed(0)}%
        </Text>
        <Text style={{ color: textSecondary, fontSize: 11 }}>
          Estado: {project.status ?? '-'}
        </Text>
        <View style={{ flex: 1 }} />
        <TouchableOpacity onPress={onOpen} style={s.cardBtn}>
          <Text style={{ color: '#fff', fontWeight: '700', fontSize: 12 }}>Ver detalhes</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

/* ===== helpers (mocks) ===== */
function showMockProfile() {
  Alert.alert(
    'Perfil (mock)',
    'Nome: Usuário Demo\nEmail: demo@exemplo.com\nPlano: Básico',
    [{ text: 'Fechar' }],
  );
}

/* ===== styles ===== */
const s = StyleSheet.create({
  fill: { flex: 1 },
  retryBtn: {
    height: 44, paddingHorizontal: 16, borderRadius: 10,
    backgroundColor: primary, alignItems: 'center', justifyContent: 'center',
  },
  card: {
    width: '48%',
    marginBottom: 12,
    backgroundColor: '#fff',
    borderRadius: 12,
    overflow: 'hidden',
    ...(Platform.OS === 'android'
      ? { elevation: 2 }
      : { shadowColor: '#000', shadowOpacity: 0.06, shadowRadius: 10, shadowOffset: { width: 0, height: 4 } }),
  },
  cardBtn: {
    width: '100%',
    height: 30,
    backgroundColor: primary,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sheetBackdrop: { flex: 1, backgroundColor: 'rgba(0,0,0,0.2)' },
  sheet: {
    position: 'absolute', left: 0, right: 0, bottom: 0,
    backgroundColor: '#fff',
    borderTopLeftRadius: 16, borderTopRightRadius: 16,
    paddingHorizontal: 16, paddingTop: 8, paddingBottom: 16,
  },
  grabber: {
    alignSelf: 'center', width: 40, height: 5, borderRadius: 999, backgroundColor: '#D1D5DB', marginBottom: 12,
  },
  notifRow: {
    flexDirection: 'row', alignItems: 'center', paddingVertical: 10, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#E5E7EB',
  },
  notifIcon: {
    width: 36, height: 36, borderRadius: 18, backgroundColor: '#E7F5EA', alignItems: 'center', justifyContent: 'center', marginRight: 12,
  },
});

export default ProjectsView;
