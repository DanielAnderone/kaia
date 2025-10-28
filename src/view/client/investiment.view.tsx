// src/screens/investor/InvestmentsView.tsx
import React, { useEffect, useMemo, useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  RefreshControl,
  StyleSheet,
  Modal,
  Pressable,
  useColorScheme,
} from 'react-native';

// ajuste estes imports para o teu projeto
import type { Investment } from '../../models/model';
import { AppBottomNav, AppTab } from '../../widegts/app.bottom';
import { InvestmentService } from '../../service/investiment.service';

type Props = {
  projectNameOf?: (projectId: number) => string;
  investments?: Investment[];
};

enum FilterKind { active = 'active', inactive = 'inactive' }

const primary = '#169C1D';
const bgLight = '#F6F8F6';
const bgDark = '#112112';

const InvestmentsView: React.FC<Props> = ({ projectNameOf, investments = [] }) => {
  const isDark = useColorScheme() === 'dark';

  const [items, setItems] = useState<Investment[]>(investments);
  const service = useMemo(() => new InvestmentService(), []);
  const [filter, setFilter] = useState<FilterKind>(FilterKind.active);
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(false);

  // modal
  const [sel, setSel] = useState<Investment | null>(null);
  const [selTitle, setSelTitle] = useState('');

  useEffect(() => {
    loadFromApi();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const loadFromApi = async () => {
    setLoading(true);
    try {
      const list = await service.getAll();
      setItems(list);
    } catch (e) {
      setItems(mock());
    } finally {
      setLoading(false);
    }
  };

  const titleOf = (i: Investment) =>
    projectNameOf?.(i.projectId) ?? `Projeto #${i.projectId}`;

  const active = items.filter(i => (i.actualProfit ?? 0) <= 0);
  const inactive = items.filter(i => (i.actualProfit ?? 0) > 0);
  let list = filter === FilterKind.active ? active : inactive;

  if (query.trim()) {
    const q = query.trim().toLowerCase();
    list = list.filter(i => titleOf(i).toLowerCase().includes(q));
  }

  const totalCount = list.length;
  const totalInvested = list.reduce((s, i) => s + (i.investedAmount ?? 0), 0);
  const totalProfit = list.reduce(
    (s, i) =>
      s + (filter === FilterKind.active ? (i.estimatedProfit ?? 0) : (i.actualProfit ?? 0)),
    0
  );

  return (
    <View style={{ flex: 1, backgroundColor: isDark ? bgDark : bgLight }}>
      <View style={[s.appbar, { backgroundColor: isDark ? bgDark : bgLight }]}>
        <TouchableOpacity onPress={() => (/* nav.goBack() se quiser */ null)}>
          <Text style={{ color: isDark ? '#fff' : '#111', fontSize: 18 }}>{'‹'}</Text>
        </TouchableOpacity>
        <Text style={[s.title, { color: isDark ? '#fff' : '#111' }]}>Meus Investimentos</Text>
        <TouchableOpacity disabled={loading} onPress={loadFromApi}>
          {loading ? (
            <Text style={{ color: primary }}>⟳</Text>
          ) : (
            <Text style={{ color: isDark ? '#fff' : '#111' }}>⟳</Text>
          )}
        </TouchableOpacity>
      </View>

      <ScrollView
        refreshControl={<RefreshControl refreshing={loading} onRefresh={loadFromApi} colors={[primary]} />}
        contentContainerStyle={{ padding: 16, paddingTop: 8 }}
      >
        {/* Busca + filtro */}
        <View style={{ flexDirection: 'row' }}>
          <View style={{ flex: 1 }}>
            <TextInput
              placeholder="Pesquisar investimentos"
              placeholderTextColor="#6B7280"
              value={query}
              onChangeText={t => {
                setQuery(t);
                // se quiser refetch a cada digitação como Flutter:
                // loadFromApi();
              }}
              style={s.search}
            />
          </View>
          <View style={{ width: 10 }} />
          <View style={{ width: 150 }}>
            <View style={s.filterBox}>
              <TouchableOpacity
                style={[s.filterBtn, filter === FilterKind.active && s.filterBtnActive]}
                onPress={() => setFilter(FilterKind.active)}
              >
                <Text style={[s.filterTxt, filter === FilterKind.active && s.filterTxtActive]}>
                  Ativos
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[s.filterBtn, filter === FilterKind.inactive && s.filterBtnActive]}
                onPress={() => setFilter(FilterKind.inactive)}
              >
                <Text style={[s.filterTxt, filter === FilterKind.inactive && s.filterTxtActive]}>
                  Não ativos
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>

        {/* Cards resumo */}
        <View style={{ height: 12 }} />
        <View style={{ flexDirection: 'row' }}>
          <View style={{ flex: 1 }}>
            <SummaryCard title="Investimentos" value={String(totalCount)} />
          </View>
          <View style={{ width: 8 }} />
          <View style={{ flex: 1 }}>
            <SummaryCard title="Investido" value={mt(totalInvested)} />
          </View>
          <View style={{ width: 8 }} />
          <View style={{ flex: 1 }}>
            <SummaryCard
              title={filter === FilterKind.active ? 'Retorno estimado' : 'Retorno real'}
              value={mt(totalProfit)}
            />
          </View>
        </View>

        <View style={{ height: 16 }} />
        {loading && items.length === 0 ? (
          <View style={{ padding: 24, alignItems: 'center' }}>
            <Text>Carregando…</Text>
          </View>
        ) : list.length === 0 ? (
          <Empty message={filter === FilterKind.active ? 'Sem investimentos ativos.' : 'Sem investimentos não ativos.'} />
        ) : (
          list.map(i => {
            const isActive = (i.actualProfit ?? 0) <= 0;
            return (
              <InvestmentRow
                key={i.id}
                title={titleOf(i)}
                invested={i.investedAmount}
                profitLabel={filter === FilterKind.active ? 'Estimado:' : 'Real:'}
                profitValue={filter === FilterKind.active ? i.estimatedProfit : i.actualProfit}
                date={i.applicationDate}
                statusChip={
                  <Chip
                    text={isActive ? 'Active' : 'Completed'}
                    bg={isActive ? '#E8F8EE' : '#E9F0FF'}
                    fg={isActive ? primary : '#3B82F6'}
                  />
                }
                onPress={() => {
                  setSel(i);
                  setSelTitle(titleOf(i));
                }}
              />
            );
          })
        )}
      </ScrollView>

      <AppBottomNav current={AppTab.investments} />

      {/* Modal detalhes */}
      <Modal
        visible={!!sel}
        transparent
        animationType="slide"
        onRequestClose={() => setSel(null)}
      >
        <Pressable style={s.sheetBackdrop} onPress={() => setSel(null)} />
        <View style={s.sheet}>
          <View style={s.grabber} />
          {sel && (
            <View style={{ paddingHorizontal: 16, paddingBottom: 20 }}>
              <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                <View style={{ flex: 1 }}>
                  <Text style={s.sheetTitle} numberOfLines={2}>{selTitle}</Text>
                </View>
                <Chip
                  text={(sel.actualProfit ?? 0) > 0 ? 'Completed' : 'Active'}
                  bg={(sel.actualProfit ?? 0) > 0 ? '#E9F0FF' : '#E8F8EE'}
                  fg={(sel.actualProfit ?? 0) > 0 ? '#3B82F6' : primary}
                />
              </View>

              <View style={{ height: 12 }} />
              <KV k="Investido" v={mt(sel.investedAmount)} />
              <KV
                k={(sel.actualProfit ?? 0) > 0 ? 'Retorno real' : 'Retorno estimado'}
                v={mt((sel.actualProfit ?? 0) > 0 ? sel.actualProfit : sel.estimatedProfit)}
              />
              <KV k="Aplicado em" v={fmtDate(sel.applicationDate)} />
              {!!sel.note && <KV k="Nota" v={sel.note} />}

              <View style={{ height: 14 }} />
              <TouchableOpacity style={s.closeBtn} onPress={() => setSel(null)}>
                <Text style={{ color: primary, fontWeight: '700' }}>Fechar</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>
      </Modal>
    </View>
  );
};

/* ===== widgets ===== */

const SummaryCard: React.FC<{ title: string; value: string }> = ({ title, value }) => (
  <View style={s.card}>
    <Text style={s.cardTitle}>{title}</Text>
    <View style={{ height: 6 }} />
    <Text style={s.cardValue}>{value}</Text>
  </View>
);

const Chip: React.FC<{ text: string; bg: string; fg: string }> = ({ text, bg, fg }) => (
  <View style={[s.chip, { backgroundColor: bg }]}>
    <Text style={[s.chipTxt, { color: fg }]}>{text}</Text>
  </View>
);

const InvestmentRow: React.FC<{
  title: string;
  invested: number;
  profitLabel: string;
  profitValue: number;
  date: Date;
  statusChip: React.ReactNode;
  onPress?: () => void;
}> = ({ title, invested, profitLabel, profitValue, date, statusChip, onPress }) => (
  <View style={s.rowWrap}>
    <Pressable android_ripple={{ color: '#00000010' }} style={s.rowBtn} onPress={onPress}>
      <View style={s.iconBox}><Text style={{ color: '#4F46E5' }}>💳</Text></View>
      <View style={{ width: 12 }} />
      <View style={{ flex: 1 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center' }}>
          <Text numberOfLines={1} style={s.rowTitle}>{title}</Text>
          <View style={{ flex: 1 }} />
          {statusChip}
        </View>
        <View style={{ height: 6 }} />
        <Text style={s.rowMuted}>Invested: {mt(invested)}</Text>
        <View style={{ height: 2 }} />
        <View style={{ flexDirection: 'row', alignItems: 'center' }}>
          <Text style={s.rowMuted}>{profitLabel} </Text>
          <Text style={s.rowProfit}>{mt(profitValue)}</Text>
          <Text style={[s.rowProfit, { color: primary }]}> ↑</Text>
        </View>
        <View style={{ height: 2 }} />
        <Text style={s.rowDate}>{fmtDate(date)}</Text>
      </View>
    </Pressable>
  </View>
);

const KV: React.FC<{ k: string; v: string }> = ({ k, v }) => (
  <View style={s.kv}>
    <Text style={s.kvKey}>{k}</Text>
    <Text style={s.kvVal} numberOfLines={3}>{v}</Text>
  </View>
);

/* ===== helpers ===== */
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

function fmtDate(d: Date) {
  const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return `${m[d.getMonth()]} ${d.getDate()}, ${d.getFullYear()}`;
}

function mock(): Investment[] {
  const now = new Date();
  return [
    {
      id: 1,
      projectId: 101,
      investorId: 1,
      investedAmount: 5000,
      applicationDate: new Date(now.getFullYear(), 5, 15),
      estimatedProfit: 1250,
      actualProfit: 0,
      note: 'Lote 12',
      createdAt: new Date(now.getFullYear(), 5, 15),
      updatedAt: null,
    } as any,
    {
      id: 2,
      projectId: 102,
      investorId: 1,
      investedAmount: 3000,
      applicationDate: new Date(now.getFullYear(), 4, 20),
      estimatedProfit: 750,
      actualProfit: 0,
      note: 'Lote 08',
      createdAt: new Date(now.getFullYear(), 4, 20),
      updatedAt: null,
    } as any,
    {
      id: 3,
      projectId: 103,
      investorId: 1,
      investedAmount: 10000,
      applicationDate: new Date(now.getFullYear(), 3, 10),
      estimatedProfit: 0,
      actualProfit: 2800,
      note: 'Lote 05',
      createdAt: new Date(now.getFullYear(), 3, 10),
      updatedAt: new Date(now.getFullYear(), 8, 30),
    } as any,
  ];
}

/* ===== styles ===== */
const s = StyleSheet.create({
  appbar: {
    height: 56,
    paddingHorizontal: 12,
    flexDirection: 'row',
    alignItems: 'center',
  },
  title: { flex: 1, textAlign: 'center', fontWeight: '800' },
  search: {
    backgroundColor: '#fff',
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    paddingHorizontal: 12,
    paddingVertical: 10,
    color: '#111',
  },
  filterBox: {
    backgroundColor: primary,
    borderRadius: 10,
    flexDirection: 'row',
    overflow: 'hidden',
  },
  filterBtn: { flex: 1, paddingVertical: 8, alignItems: 'center' },
  filterBtnActive: { backgroundColor: '#128316' },
  filterTxt: { color: '#111', fontWeight: '600' },
  filterTxtActive: { color: '#fff', fontWeight: '700' },

  card: { backgroundColor: '#fff', borderRadius: 12, padding: 14 },
  cardTitle: { color: '#6B7280', fontSize: 12 },
  cardValue: { color: '#111827', fontSize: 18, fontWeight: '800' },

  rowWrap: {
    marginBottom: 10,
    backgroundColor: '#fff',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  rowBtn: { flexDirection: 'row', paddingHorizontal: 12, paddingVertical: 12, borderRadius: 12 },
  iconBox: {
    width: 44,
    height: 44,
    backgroundColor: '#EFF2FF',
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  rowTitle: { color: '#111827', fontWeight: '700', flexShrink: 1 },
  rowMuted: { color: '#6B7280', fontSize: 12 },
  rowProfit: { color: '#169C1D', fontSize: 12, fontWeight: '700' },
  rowDate: { color: '#6B7280', fontSize: 11 },

  chip: { paddingHorizontal: 10, paddingVertical: 6, borderRadius: 999 },
  chipTxt: { fontWeight: '700', fontSize: 12 },

  sheetBackdrop: { flex: 1, backgroundColor: 'rgba(0,0,0,0.2)' },
  sheet: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    paddingTop: 8,
    paddingBottom: 8,
    position: 'absolute',
    left: 0, right: 0, bottom: 0,
  },
  grabber: {
    alignSelf: 'center',
    width: 40, height: 5, borderRadius: 999, backgroundColor: '#D1D5DB', marginBottom: 12,
  },
  sheetTitle: { fontSize: 18, fontWeight: '800', color: '#111827' },
  kv: {
    flexDirection: 'row',
    paddingVertical: 4,
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  kvKey: { color: '#6B7280', fontSize: 13 },
  kvVal: { color: '#111827', textAlign: 'right', flexShrink: 1, marginLeft: 12 },
  closeBtn: {
    height: 44,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1, borderColor: primary,
  },
});

export default InvestmentsView;
