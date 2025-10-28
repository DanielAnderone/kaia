import React, { useCallback, useEffect, useMemo, useState } from 'react';
import {
  SafeAreaView,
  View,
  Text,
  TextInput,
  FlatList,
  TouchableOpacity,
  RefreshControl,
  Modal,
  Pressable,
  StyleSheet,
} from 'react-native';
import { AppBottomNav, AppTab } from '../../widegts/app.bottom';
import { Transaction } from '../../models/model';
import { TransactionService } from '../../service/transactions.service';

type TxFilter = 'all' | 'pending' | 'processing' | 'approved' | 'failed' | 'refunded';

const GREEN = '#169C1D';
const RED = '#E53935';
const BG_LIGHT = '#FFFFFF';

export const TransactionsScreen: React.FC<{ initial?: Transaction[] }> = ({ initial = [] }) => {
  const [all, setAll] = useState<Transaction[]>(initial);
  const [loading, setLoading] = useState(false);
  const [q, setQ] = useState('');
  const [filter, setFilter] = useState<TxFilter>('all');
  const [seed, setSeed] = useState(0);
  const [modal, setModal] = useState<{ open: boolean; tx?: Transaction }>({ open: false });

  const svc = useMemo(() => new TransactionService(), []);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const list = await svc.getAll();
      setAll(list);
    } catch (e) {
      setSeed((s) => s + 1);
      setAll(mock(seed + 1));
    } finally {
      setLoading(false);
    }
  }, [seed, svc]);

  useEffect(() => {
    load();
  }, [load]);

  const filtered = useMemo(() => {
    let it = [...all];
    if (filter !== 'all') it = it.filter((t) => statusOf(t) === filter);
    if (q.trim()) {
      const s = q.toLowerCase();
      it = it.filter(
        (t) =>
          t.transactionId.toLowerCase().includes(s) ||
          t.gatewayRef.toLowerCase().includes(s) ||
          t.payerAccount.toLowerCase().includes(s),
      );
    }
    return it;
  }, [all, filter, q]);

  const total = useMemo(() => filtered.reduce((s, t) => s + t.amount, 0), [filtered]);
  const approvedCount = useMemo(() => filtered.filter((t) => statusOf(t) === 'approved').length, [filtered]);
  const failedCount = useMemo(() => filtered.filter((t) => statusOf(t) === 'failed').length, [filtered]);

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: BG_LIGHT }}>
      <View style={s.header}>
        <Pressable style={s.iconBtn} onPress={loading ? undefined : load}>
          <Text style={{ color: loading ? '#999' : '#000' }}>{loading ? '⟳' : '⟳'}</Text>
        </Pressable>
        <Text style={s.headerTitle}>Transações</Text>
        <View style={s.iconBtn} />
      </View>

      <FlatList
        contentContainerStyle={{ padding: 16, paddingBottom: 100 }}
        data={filtered}
        keyExtractor={(_, i) => String(i)}
        refreshControl={<RefreshControl refreshing={loading} onRefresh={load} tintColor={GREEN} />}
        ListHeaderComponent={
          <>
            <TextInput
              value={q}
              onChangeText={(v) => {
                setQ(v);
                load(); // mantém o mesmo comportamento do Flutter: recarrega ao digitar
              }}
              placeholder="Buscar por ID, referência..."
              style={s.search}
              placeholderTextColor="#6B7280"
            />
            <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 10 }}>
              <View style={{ flex: 1, flexDirection: 'row' }}>
                {(
                  [
                    ['Todos', 'all'],
                    ['Pendente', 'pending'],
                    ['Aprovada', 'approved'],
                    ['Falhada', 'failed'],
                    ['Processando', 'processing'],
                    ['Reembolsada', 'refunded'],
                  ] as [string, TxFilter][]
                ).map(([label, key]) => (
                  <Chip key={key} label={label} selected={filter === key} onPress={() => setFilter(key)} />
                ))}
              </View>
              <View style={s.roundIcon}>
                <Text style={{ color: GREEN }}>📅</Text>
              </View>
            </View>

            <View style={{ flexDirection: 'row', gap: 8, marginTop: 12 }}>
              <SummaryCard title="Total no período" value={money(total)} valueColor="#111827" />
              <SummaryCard title="Aprovadas" value={String(approvedCount)} valueColor={GREEN} />
              <SummaryCard title="Falhadas" value={String(failedCount)} valueColor={RED} />
            </View>

            {filtered.length === 0 && (
              <View style={s.empty}>
                <Text style={s.emptyIcon}>🧾</Text>
                <Text style={s.emptyTitle}>Sem transações no período</Text>
                <Text style={s.emptySub}>Ajuste os filtros ou escolha outro período.</Text>
              </View>
            )}
          </>
        }
        renderItem={({ item }) => (
          <TxCard
            tx={item}
            onPress={() => setModal({ open: true, tx: item })}
          />
        )}
      />

      <Modal visible={modal.open} transparent animationType="slide" onRequestClose={() => setModal({ open: false })}>
        <Pressable style={s.modalBack} onPress={() => setModal({ open: false })}>
          <Pressable style={s.sheet} onPress={() => {}}>
            <View style={s.sheetGrab} />
            {modal.tx && <TxDetails tx={modal.tx} onClose={() => setModal({ open: false })} />}
          </Pressable>
        </Pressable>
      </Modal>

      <AppBottomNav current={AppTab.transacao} />
    </SafeAreaView>
  );
};

/* ---------------- Helpers ---------------- */

const statusOf = (t: Transaction): TxFilter => {
  switch (t.paymentId) {
    case 1:
      return 'approved';
    case 2:
      return 'pending';
    case 3:
      return 'failed';
    case 4:
      return 'processing';
    case 5:
      return 'refunded';
    default:
      return 'pending';
  }
};

const money = (v: number, curr = 'MT') => {
  const s = v.toFixed(2);
  const [intPart, frac] = s.split('.');
  let out = '';
  let c = 0;
  for (let i = intPart.length - 1; i >= 0; i--) {
    out += intPart[i];
    c++;
    if (c === 3 && i !== 0) {
      out += '.';
      c = 0;
    }
  }
  return `${curr} ${out.split('').reverse().join('')},${frac}`;
};

const mask = (s: string) => (s.length <= 4 ? s : `•••• ${s.slice(-4)}`);
const shortId = (s: string) => (s.length <= 7 ? s : `${s.slice(0, 6)}...`);

const statusVisual = (st: TxFilter): { dot: string; fg: string; label: string } => {
  switch (st) {
    case 'approved':
      return { dot: GREEN, fg: GREEN, label: 'Aprovada' };
    case 'failed':
      return { dot: RED, fg: RED, label: 'Falhada' };
    case 'pending':
      return { dot: '#9CA3AF', fg: '#6B7280', label: 'Pendente' };
    case 'processing':
      return { dot: '#9CA3AF', fg: '#6B7280', label: 'Processando' };
    case 'refunded':
      return { dot: '#9CA3AF', fg: '#6B7280', label: 'Reembolsada' };
    default:
      return { dot: '#9CA3AF', fg: '#6B7280', label: st };
  }
};

const mock = (seed = 0): Transaction[] => [
  {
    id: 1,
    paymentId: seed % 2 === 0 ? 1 : 4,
    investorId: 7,
    payerAccount: '258841231234',
    gatewayRef: '123456789',
    transactionId: '456789123',
    amount: 150.0,
  },
  {
    id: 2,
    paymentId: 2,
    investorId: 7,
    payerAccount: '258848765678',
    gatewayRef: '456789111',
    transactionId: '789222333',
    amount: 75.5,
  },
  {
    id: 3,
    paymentId: 3,
    investorId: 7,
    payerAccount: '258849009012',
    gatewayRef: '789000999',
    transactionId: '123000111',
    amount: 2300.0,
  },
  {
    id: 4,
    paymentId: 5,
    investorId: 7,
    payerAccount: '258847897890',
    gatewayRef: '555000111',
    transactionId: '111222333',
    amount: 99.9,
  },
];

/* ---------------- UI Pieces ---------------- */

const Chip: React.FC<{ label: string; selected?: boolean; onPress?: () => void }> = ({ label, selected, onPress }) => (
  <TouchableOpacity onPress={onPress} style={[s.chip, selected && { backgroundColor: '#E6F5EC', borderColor: GREEN }]}>
    <Text style={[s.chipText, selected && { color: GREEN }]}>{label}</Text>
  </TouchableOpacity>
);

const SummaryCard: React.FC<{ title: string; value: string; valueColor: string }> = ({ title, value, valueColor }) => (
  <View style={s.summary}>
    <Text style={s.summaryTitle}>{title}</Text>
    <Text style={[s.summaryValue, { color: valueColor }]}>{value}</Text>
  </View>
);

const TxCard: React.FC<{ tx: Transaction; onPress?: () => void }> = ({ tx, onPress }) => {
  const st = statusOf(tx);
  const { dot, fg, label } = statusVisual(st);
  return (
    <TouchableOpacity onPress={onPress} activeOpacity={0.8} style={s.card}>
      <View style={s.rowBetween}>
        <View style={s.row}>
          <View style={[s.dot, { backgroundColor: dot }]} />
          <Text style={[s.statusText, { color: fg }]}>{label}</Text>
        </View>
        <Text style={s.amount}>{money(tx.amount)}</Text>
      </View>
      <View style={[s.rowBetween, { marginTop: 6 }]}>
        <Text style={s.muted}>{mask(tx.payerAccount)}</Text>
        <Text style={s.muted2}>{shortId(tx.transactionId)}</Text>
      </View>
    </TouchableOpacity>
  );
};

const TxDetails: React.FC<{ tx: Transaction; onClose: () => void }> = ({ tx, onClose }) => {
  const st = statusOf(tx);
  const { dot, fg, label } = statusVisual(st);
  return (
    <View>
      <View style={s.rowBetween}>
        <View style={s.row}>
          <View style={[s.dot, { width: 12, height: 12, backgroundColor: dot }]} />
          <Text style={[s.sheetTitle, { color: fg }]}>{label}</Text>
        </View>
        <Text style={s.sheetAmount}>{money(tx.amount)}</Text>
      </View>
      <View style={s.divider} />
      <KV k="Moeda" v="MT" />
      <KV k="Conta" v={tx.payerAccount} />
      <KV k="Gateway Ref" v={tx.gatewayRef} />
      <KV k="Transaction ID" v={tx.transactionId} />
      <View style={{ height: 14 }} />
      <View style={{ flexDirection: 'row', gap: 8 }}>
        <OutlinedPill text="Copiar ID" onPress={() => {}} />
        <SolidPill text="Ver no gateway" onPress={() => {}} />
      </View>
      <View style={{ height: 10 }} />
      <Pressable onPress={onClose} style={s.closeSheet}>
        <Text style={{ color: GREEN, fontWeight: '700' }}>Fechar</Text>
      </Pressable>
    </View>
  );
};

const KV: React.FC<{ k: string; v: string }> = ({ k, v }) => (
  <View style={s.kv}>
    <Text style={s.kLabel}>{k}</Text>
    <Text style={s.kValue}>{v}</Text>
  </View>
);

const OutlinedPill: React.FC<{ text: string; onPress: () => void }> = ({ text, onPress }) => (
  <Pressable onPress={onPress} style={s.outlinedPill}>
    <Text style={{ color: GREEN, fontWeight: '700' }}>{text}</Text>
  </Pressable>
);

const SolidPill: React.FC<{ text: string; onPress: () => void }> = ({ text, onPress }) => (
  <Pressable onPress={onPress} style={s.solidPill}>
    <Text style={{ color: '#fff', fontWeight: '700' }}>{text}</Text>
  </Pressable>
);

/* ---------------- Styles ---------------- */

const s = StyleSheet.create({
  header: {
    height: 56,
    backgroundColor: BG_LIGHT,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
  },
  iconBtn: { width: 40, alignItems: 'center' },
  headerTitle: { flex: 1, textAlign: 'center', fontWeight: '700', fontSize: 18, color: '#111827' },

  search: {
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 10,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 14,
    color: '#111827',
  },
  roundIcon: {
    width: 44,
    height: 44,
    backgroundColor: '#FFFFFF',
    borderRadius: 999,
    alignItems: 'center',
    justifyContent: 'center',
    marginLeft: 8,
  },

  chip: {
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 999,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    marginRight: 8,
  },
  chipText: { color: '#111827', fontWeight: '600' },

  summary: { flex: 1, backgroundColor: '#FFFFFF', borderRadius: 12, padding: 14 },
  summaryTitle: { color: '#6B7280', fontSize: 12 },
  summaryValue: { fontSize: 20, fontWeight: '800', marginTop: 6 },

  empty: { backgroundColor: '#FFFFFF', borderRadius: 12, padding: 24, alignItems: 'center', marginTop: 14 },
  emptyIcon: { fontSize: 40, color: '#9CA3AF' },
  emptyTitle: { color: '#111827', fontWeight: '700', marginTop: 8 },
  emptySub: { color: '#6B7280', fontSize: 12, marginTop: 4 },

  card: {
    marginTop: 10,
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 12,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  row: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  rowBetween: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  dot: { width: 10, height: 10, borderRadius: 999 },
  statusText: { fontWeight: '700' },
  amount: { color: '#111827', fontWeight: '700', fontSize: 16 },
  muted: { color: '#6B7280', fontSize: 12 },
  muted2: { color: '#9CA3AF', fontSize: 12 },

  modalBack: { flex: 1, backgroundColor: 'rgba(0,0,0,0.25)', justifyContent: 'flex-end' },
  sheet: { backgroundColor: '#FFFFFF', borderTopLeftRadius: 16, borderTopRightRadius: 16, padding: 16 },
  sheetGrab: {
    alignSelf: 'center',
    width: 40,
    height: 5,
    borderRadius: 999,
    backgroundColor: '#D1D5DB',
    marginBottom: 10,
  },
  sheetTitle: { fontSize: 16, fontWeight: '700', marginLeft: 8 },
  sheetAmount: { fontSize: 22, fontWeight: '800', color: '#111827' },
  divider: { height: 1, backgroundColor: '#E5E7EB', marginVertical: 10 },

  kv: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 4 },
  kLabel: { color: '#6B7280', fontSize: 13 },
  kValue: { color: '#111827', textAlign: 'right' },

  outlinedPill: {
    flex: 1,
    height: 44,
    borderWidth: 1,
    borderColor: GREEN,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  solidPill: {
    flex: 1,
    height: 44,
    backgroundColor: GREEN,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  closeSheet: {
    height: 44,
    borderWidth: 1,
    borderColor: GREEN,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default TransactionsScreen;
