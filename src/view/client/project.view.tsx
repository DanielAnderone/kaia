// src/screens/investor/ProjectsView.tsx
import React, { useMemo, useState, useEffect } from 'react';
import {
  View, Text, FlatList, TouchableOpacity, ActivityIndicator,
  useColorScheme, useWindowDimensions, StyleSheet, Platform, Alert,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';

import type { Project, User } from '../../models/model';
import { ProjectService } from '../../service/project.service';
import { SesManager } from '../../utils/token.management';

import NetImage from '../../widegts/netImage';
import { AppBottomNav, AppTab } from '../../widegts/app.bottom';

const primary = '#169C1D';
const bgLight = '#F6F8F6';
const bgDark = '#112112';

const ProjectsView: React.FC = () => {
  const isDark = useColorScheme() === 'dark';
  const { width } = useWindowDimensions();
  const nav = useNavigation<any>();

  // service único para reutilizar inclusive na URL da imagem
  const service = useMemo(() => new ProjectService(), []);
  const projCols = Math.max(2, Math.min(3, Math.floor(width / 180)));

  const [state, setState] = useState<{
    status: 'idle' | 'loading' | 'done' | 'error';
    data: Project[];
    error?: string;
  }>({ status: 'loading', data: [] });

  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    let mounted = true;

    const loadUser = async () => {
      try {
        const u = await SesManager.getPayload();
        if (mounted) setUser(u);
      } catch {}
    };

    const loadProjects = async () => {
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

    loadUser();
    loadProjects();
    return () => { mounted = false; };
  }, [service]);

  const retry = () => {
    setState({ status: 'loading', data: [] });
    service.listProjects()
      .then(list => setState({ status: 'done', data: list }))
      .catch(e => setState({ status: 'error', data: [], error: String(e?.message || e) }));
  };

  const logout = async () => {
    try {
      await SesManager.delete();
    } finally {
      nav.reset({ index: 0, routes: [{ name: 'Login' }] });
    }
  };

  // gera URL via /projects/download/{id} com placeholder se faltar id
  const projectImageUrl = (p: Project): string => {
    const url = service.getImageUrl(p.id ?? null);
    return url ?? `https://picsum.photos/seed/${p.id ?? 'default'}/600/400`;
  };

  const header = (
    <View style={{ backgroundColor: isDark ? bgDark : bgLight }}>
      <View style={{ paddingHorizontal: 16, paddingTop: 12, paddingBottom: 8, flexDirection: 'row', alignItems: 'center' }}>
        <View style={styles.avatar}>
          <Text style={styles.avatarTxt}>
            {initials(user?.username || user?.email || 'U')}
          </Text>
        </View>
        <View style={{ width: 8 }} />
        <View style={{ flex: 1 }}>
          <Text style={{ color: isDark ? '#fff' : '#111', fontSize: 14, opacity: 0.8 }}>Olá</Text>
          <Text numberOfLines={1} style={{ color: isDark ? '#fff' : '#111', fontSize: 18, fontWeight: '700' }}>
            {user?.username || user?.email || 'Utilizador'}
          </Text>
        </View>
        <TouchableOpacity
          onPress={() => {
            Alert.alert('Sair', 'Deseja terminar a sessão?', [
              { text: 'Cancelar', style: 'cancel' },
              { text: 'Sair', style: 'destructive', onPress: logout },
            ]);
          }}
          style={styles.logoutBtn}
        >
          <Text style={{ color: '#fff', fontWeight: '700' }}>Sair</Text>
        </TouchableOpacity>
      </View>

      <View style={{ paddingHorizontal: 16, paddingTop: 4, paddingBottom: 8 }}>
        <Text style={{ color: isDark ? '#fff' : '#111', fontSize: 22, fontWeight: '700' }}>Projetos</Text>
      </View>
    </View>
  );

  if (state.status === 'loading') {
    return (
      <View style={[styles.fill, { backgroundColor: bgLight, alignItems: 'center', justifyContent: 'center' }]}>
        <ActivityIndicator />
        <AppBottomNav current={AppTab.Inicio} />
      </View>
    );
  }

  if (state.status === 'error') {
    return (
      <View style={[styles.fill, { backgroundColor: bgLight, alignItems: 'center', justifyContent: 'center', padding: 16 }]}>
        <Text>Erro ao carregar projetos</Text>
        <View style={{ height: 8 }} />
        <TouchableOpacity onPress={retry} style={styles.retryBtn}>
          <Text style={{ color: '#fff', fontWeight: '700' }}>Tentar novamente</Text>
        </TouchableOpacity>
        <AppBottomNav current={AppTab.Inicio} />
      </View>
    );
  }

  return (
    <View style={[styles.fill, { backgroundColor: bgLight }]}>
      <FlatList
        ListHeaderComponent={header}
        data={state.data}
        key={projCols}
        numColumns={projCols}
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 64 }}
        columnWrapperStyle={projCols > 1 ? { justifyContent: 'space-between' } : undefined}
        keyExtractor={(item, idx) => String((item as any)?.id ?? idx)}
        renderItem={({ item }) => (
          <ProjectCard
            project={item}
            getImg={projectImageUrl}
            onOpen={() => nav.navigate('InvestorProjects')}
          />
        )}
      />
      <AppBottomNav current={AppTab.Inicio} />
    </View>
  );
};

const ProjectCard: React.FC<{ project: Project; getImg: (p: Project) => string; onOpen: () => void }> = ({ project, getImg, onOpen }) => {
  const isDark = useColorScheme() === 'dark';
  const textPrimary = isDark ? '#fff' : '#111827';
  const textSecondary = isDark ? '#D1D5DB' : '#111827';
  const img = getImg(project);

  return (
    <View style={styles.card}>
      <View style={{ borderTopLeftRadius: 12, borderTopRightRadius: 12, overflow: 'hidden', aspectRatio: 16 / 10 }}>
        <NetImage url={img} fit="cover" style={{ width: '100%', height: '100%' }} />
      </View>

      <View style={{ flex: 1, paddingHorizontal: 10, paddingTop: 6, paddingBottom: 8 }}>
        <Text numberOfLines={2} style={{ color: textPrimary, fontSize: 12.5, fontWeight: '700' }}>
          {((project as any)?.description || (project as any)?.name || 'Sem nome') as string}
        </Text>
        <View style={{ height: 4 }} />
        <Text style={{ color: textSecondary, fontSize: 11 }}>
          Mín. investimento: MT {Number((project as any)?.minimumInvestment ?? 0).toFixed(0)}
        </Text>
        <Text style={{ color: textSecondary, fontSize: 11 }}>
          Rentabilidade: {Number((project as any)?.profitabilityPercent ?? 0).toFixed(0)}%
        </Text>
        <Text style={{ color: textSecondary, fontSize: 11 }}>
          Estado: {((project as any)?.status ?? '-') as string}
        </Text>
        <View style={{ flex: 1 }} />
        <TouchableOpacity onPress={onOpen} style={styles.cardBtn}>
          <Text style={{ color: '#fff', fontWeight: '700', fontSize: 12 }}>Ver detalhes</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

function initials(s?: string) {
  if (!s) return 'U';
  const parts = s.trim().split(/\s+/);
  const first = parts[0]?.[0] ?? '';
  const last = parts.length > 1 ? parts[parts.length - 1][0] ?? '' : '';
  return (first + last).toUpperCase() || 'U';
}

const styles = StyleSheet.create({
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
  avatar: {
    width: 40, height: 40, borderRadius: 20,
    backgroundColor: '#E7F5EA',
    alignItems: 'center', justifyContent: 'center',
  },
  avatarTxt: { color: primary, fontWeight: '800' },
  logoutBtn: {
    height: 32,
    paddingHorizontal: 12,
    backgroundColor: '#EF4444',
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default ProjectsView;
