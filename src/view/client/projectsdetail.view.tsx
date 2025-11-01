// src/screens/investor/ProjectDetailsView.tsx
import React, { useMemo, useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  useColorScheme,
  Modal,
  TextInput,
  Pressable,
  Alert,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';

import type { Project, Investor } from '../../models/model';
// REMOVIDO: import { projectImageUrl } from '../../models/model';
import NetImage from '../../widegts/netImage';
import { InvestorService } from '../../service/investor.service';

const primary = '#169C1D';
const bgLight = '#F6F8F6';
const bgDark = '#112112';

type Params = { project: Project };

/** === helper local para imagem do projeto === */
function projectImageUrl(p?: Partial<Project> | any): string {
  if (!p) return '';
  // tenta array de imagens
  const imgs = (p as any).images;
  if (Array.isArray(imgs) && imgs.length) {
    const v = imgs[0];
    const u = typeof v === 'string' ? v : v?.url;
    if (u) return String(u);
  }
  // fallback para campo único
  if ((p as any).image) return String((p as any).image);
  // nenhum encontrado
  return '';
}

const ProjectDetailsView: React.FC = () => {
  const isDark = useColorScheme() === 'dark';
  const nav = useNavigation<any>();
  const { params } = useRoute<any>();
  const project: Project = (params as Params).project;

  const svc = useMemo(() => new InvestorService(), []);
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);

  // form
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [born, setBorn] = useState(''); // YYYY-MM-DD
  const [identityCard, setIdentityCard] = useState('');
  const [nuit, setNuit] = useState('');

  const submitInvestor = async () => {
    if (!name.trim() || !phone.trim() || !born.trim() || !identityCard.trim() || !nuit.trim()) {
      Alert.alert('Campos obrigatórios', 'Preencha todos os campos.');
      return;
    }

    // userId mock igual ao Flutter: userIdProvider() => 1
    const payload: Investor = {
      userId: 1,
      name: name.trim(),
      phone: phone.trim(),
      bornDate: new Date(born),
      identityCard: identityCard.trim(),
      nuit: nuit.trim(),
    } as any;

    setLoading(true);
    try {
      const created = await (svc as any).create?.(payload);
      const investor: Investor = created ?? payload;

      setOpen(false);
      nav.navigate('InvestorPayments', { investor, project });
    } catch (e: any) {
      setOpen(false);
      Alert.alert('Erro ao cadastrar investidor', String(e?.message || e));
    } finally {
      setLoading(false);
    }
  };

  const img = projectImageUrl(project);

  return (
    <View style={{ flex: 1, backgroundColor: isDark ? bgDark : bgLight }}>
      {/* AppBar */}
      <View style={[s.appbar, { backgroundColor: isDark ? bgDark : bgLight }]}>
        <TouchableOpacity onPress={() => nav.goBack()}>
          <Text style={{ color: isDark ? '#fff' : '#111', fontSize: 18 }}>{'‹'}</Text>
        </TouchableOpacity>
        <Text style={[s.appbarTitle, { color: isDark ? '#fff' : '#111' }]}>Detalhes do Projeto</Text>
        <TouchableOpacity onPress={() => {}}>
          <Text style={{ color: isDark ? '#fff' : '#111', fontSize: 16 }}>⤴︎</Text>
        </TouchableOpacity>
      </View>

      <ScrollView contentContainerStyle={{ paddingBottom: 80 }}>
        {/* Imagem */}
        <View style={{ aspectRatio: 16 / 9 }}>
          <NetImage url={img} fit="cover" style={{ width: '100%', height: '100%' }} />
        </View>

        {/* Título + status */}
        <View style={{ paddingHorizontal: 16, paddingTop: 12 }}>
          <Text
            style={{
              color: isDark ? '#fff' : '#111',
              fontSize: 26,
              fontWeight: '700',
            }}
          >
            {project.description ?? 'Projeto'}
          </Text>
          <View style={{ height: 8 }} />
          <View style={[s.chip, { backgroundColor: hexWithAlpha(primary, 0.2) }]}>
            <Text style={[s.chipTxt]}>{project.status ?? 'Em progresso'}</Text>
          </View>
        </View>

        {/* Métricas */}
        <View style={{ paddingHorizontal: 16, paddingTop: 12 }}>
          <View style={s.grid}>
            <Metric icon="💵" titulo="Mín. investimento" valor={mt(project.minimumInvestment ?? 0)} />
            <Metric icon="📈" titulo="Rentabilidade" valor={`${(project.profitabilityPercent ?? 0).toFixed(0)}%`} />
            <Metric icon="🛡️" titulo="Risco" valor={riskLabel(project.riskLevel ?? '')} />
            <Metric icon="🗓️" titulo="Período" valor={''} />
            <Metric icon="👛" titulo="Arrecadado" valor={mt(project.investmentAchieved ?? 0)} />
            {project.totalProfit != null && (
              <Metric icon="📊" titulo="Lucro total" valor={mt(project.totalProfit!)} />
            )}
          </View>
        </View>

        {/* Descrição */}
        <View style={{ paddingHorizontal: 16, paddingVertical: 16 }}>
          <Text style={{ color: isDark ? '#fff' : '#111', fontWeight: '700', fontSize: 18 }}>Descrição</Text>
          <View style={{ height: 8 }} />
          <Text style={{ color: isDark ? '#D1D5DB' : '#4B5563', lineHeight: 20 }}>
            {project.description ?? 'Sem descrição disponível.'}
          </Text>
        </View>
      </ScrollView>

      {/* Bottom bar */}
      <View style={[s.bottomBar, { backgroundColor: isDark ? bgDark : bgLight }]}>
        <View style={{ flex: 1 }} />
        <TouchableOpacity style={s.cta} onPress={() => setOpen(true)}>
          <Text style={{ color: '#fff', fontWeight: '700' }}>Investir agora</Text>
        </TouchableOpacity>
      </View>

      {/* Modal de cadastro de investidor */}
      <Modal transparent animationType="slide" visible={open} onRequestClose={() => setOpen(false)}>
        <Pressable style={s.sheetBackdrop} onPress={() => setOpen(false)} />
        <View style={s.sheet}>
          <View style={s.grabber} />
          <Text style={s.sheetTitle}>Cadastro de Investidor</Text>

          <View style={s.formRow}>
            <Text style={s.label}>Nome completo</Text>
            <TextInput value={name} onChangeText={setName} style={s.input} placeholder="Ex.: João Silva" />
          </View>

          <View style={s.formRow}>
            <Text style={s.label}>Telefone</Text>
            <TextInput
              value={phone}
              onChangeText={setPhone}
              style={s.input}
              placeholder="84xxxxxxx"
              keyboardType="phone-pad"
            />
          </View>

          <View style={s.formRow}>
            <Text style={s.label}>Data de nascimento</Text>
            <TextInput
              value={born}
              onChangeText={setBorn}
              style={s.input}
              placeholder="YYYY-MM-DD"
              autoCapitalize="none"
            />
          </View>

          <View style={s.formRow}>
            <Text style={s.label}>Bilhete de Identidade / Doc.</Text>
            <TextInput value={identityCard} onChangeText={setIdentityCard} style={s.input} placeholder="XXXXXX" />
          </View>

          <View style={s.formRow}>
            <Text style={s.label}>NUIT</Text>
            <TextInput
              value={nuit}
              onChangeText={setNuit}
              style={s.input}
              placeholder="XXXXXXXXX"
              keyboardType="number-pad"
            />
          </View>

          <View style={{ height: 12 }} />
          <View style={{ flexDirection: 'row' }}>
            <View style={{ flex: 1 }}>
              <TouchableOpacity style={s.cancelBtn} onPress={() => setOpen(false)} disabled={loading}>
                <Text style={{ color: '#111' }}>Cancelar</Text>
              </TouchableOpacity>
            </View>
            <View style={{ width: 10 }} />
            <View style={{ flex: 1 }}>
              <TouchableOpacity style={s.submitBtn} onPress={submitInvestor} disabled={loading}>
                <Text style={{ color: '#111' }}>{loading ? 'Aguarde…' : 'Cadastrar'}</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
};

/* === componentes menores === */

const Metric: React.FC<{ icon: string; titulo: string; valor: string }> = ({ icon, titulo, valor }) => (
  <View style={s.metric}>
    <Text style={{ fontSize: 18 }}>{icon}</Text>
    <View style={{ width: 10 }} />
    <View style={{ flex: 1 }}>
      <Text style={{ color: '#6B7280', fontSize: 12 }} numberOfLines={1}>{titulo}</Text>
      <Text style={{ color: '#111827', fontWeight: '700', fontSize: 14 }} numberOfLines={1}>{valor}</Text>
    </View>
  </View>
);

/* === helpers === */

function riskLabel(v: string) {
  const x = v.toLowerCase();
  if (x === 'baixo') return 'Baixo';
  if (x === 'medio') return 'Médio';
  if (x === 'alto') return 'Alto';
  return v || '-';
}

function mt(v: number) {
  const s = Math.trunc(v).toString();
  let out = '';
  let c = 0;
  for (let i = s.length - 1; i >= 0; i--) {
    out = s[i] + out;
    c++;
    if (c === 3 && i !== 0) {
      out = '.' + out;
      c = 0;
    }
  }
  return `MT ${out}`;
}

function hexWithAlpha(hex: string, alpha: number) {
  const a = Math.round(alpha * 255).toString(16).padStart(2, '0');
  return `${hex}${a}`;
}

/* === styles === */

const s = StyleSheet.create({
  appbar: {
    height: 56,
    paddingHorizontal: 8,
    flexDirection: 'row',
    alignItems: 'center',
  },
  appbarTitle: { flex: 1, textAlign: 'center', fontWeight: '800', fontSize: 18 },
  chip: { alignSelf: 'flex-start', paddingHorizontal: 12, paddingVertical: 6, borderRadius: 999 },
  chipTxt: { color: primary, fontWeight: '700', fontSize: 12 },

  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  metric: {
    minHeight: 64,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 12,
    backgroundColor: '#fff',
    width: '48%',
    flexDirection: 'row',
    alignItems: 'center',
  },

  bottomBar: { paddingHorizontal: 16, paddingTop: 10, paddingBottom: 14, flexDirection: 'row' },
  cta: {
    width: '50%',
    height: 48,
    backgroundColor: primary,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },

  sheetBackdrop: { flex: 1, backgroundColor: 'rgba(0,0,0,0.25)' },
  sheet: {
    position: 'absolute', left: 0, right: 0, bottom: 0,
    backgroundColor: '#fff',
    borderTopLeftRadius: 16, borderTopRightRadius: 16,
    paddingHorizontal: 16, paddingTop: 8, paddingBottom: 16,
  },
  grabber: {
    alignSelf: 'center', width: 40, height: 5, borderRadius: 999, backgroundColor: '#D1D5DB', marginBottom: 12,
  },
  sheetTitle: { fontWeight: '800', fontSize: 16, color: '#111827', marginBottom: 8 },

  formRow: { marginBottom: 8 },
  label: { color: '#111827', marginBottom: 6, fontWeight: '600' },
  input: {
    height: 44, borderRadius: 12, borderWidth: 1, borderColor: '#E5E7EB',
    backgroundColor: '#fff', paddingHorizontal: 12, color: '#111827',
  },

  cancelBtn: {
    height: 44, borderRadius: 10, borderWidth: 1, borderColor: '#9CA3AF',
    alignItems: 'center', justifyContent: 'center', backgroundColor: '#fff',
  },
  submitBtn: {
    height: 44, borderRadius: 10, borderWidth: 1, borderColor: '#111',
    alignItems: 'center', justifyContent: 'center', backgroundColor: '#fff',
  },
});

export default ProjectDetailsView;
