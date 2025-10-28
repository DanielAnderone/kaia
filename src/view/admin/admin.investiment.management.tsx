// src/screens/admin/InvestmentManagementView.tsx
import React, { useEffect, useMemo, useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  FlatList,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { type Investment } from '@/models';
import { InvestmentService } from '@/services/investment.service';

const bg = '#F5F7FA';
const primaryBtn = '#2A64F2';

const InvestmentManagementView: React.FC = () => {
  const nav = useNavigation<any>();
  const svc = useMemo(() => new InvestmentService(), []);
  const [loading, setLoading] = useState(true);
  const [items, setItems] = useState<Investment[]>([]);
  const [error, setError] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await svc.getAll();
      setItems(data);
    } catch (e: any) {
      setError(String(e?.message || e));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <View style={{ flex: 1, backgroundColor: bg }}>
      {/* AppBar */}
      <View style={s.appbar}>
        <Text style={s.appbarTitle}>Gestão de Investimentos</Text>
      </View>

      <View style={{ padding: 16, flex: 1 }}>
        <TouchableOpacity style={[s.btn, { backgroundColor: primaryBtn }]} onPress={() => nav.goBack()}>
          <Text style={[s.btnTxt, { color: '#fff' }]}>Voltar para Dashboard</Text>
        </TouchableOpacity>

        <View style={{ height: 16 }} />

        {loading ? (
          <View style={s.center}>
            <ActivityIndicator />
          </View>
        ) : error ? (
          <View style={s.center}>
            <Text style={{ color: '#DC2626' }}>Erro: {error}</Text>
            <View style={{ height: 8 }} />
            <TouchableOpacity style={[s.btn, { backgroundColor: '#111' }]} onPress={load}>
              <Text style={[s.btnTxt, { color: '#fff' }]}>Tentar novamente</Text>
            </TouchableOpacity>
          </View>
        ) : items.length === 0 ? (
          <View style={s.center}>
            <Text>Nenhum investimento encontrado.</Text>
          </View>
        ) : (
          <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            <View>
              {/* Cabeçalho */}
              <View style={s.headerRow}>
                <ColumnHeader title="Investidor" width={150} />
                <ColumnHeader title="Projeto" width={200} />
                <ColumnHeader title="Valor" width={120} />
                <ColumnHeader title="Status" width={120} />
                {/* <ColumnHeader title="Ref. Transação" width={150} /> */}
              </View>
              <View style={{ height: 8 }} />
              {/* Linhas */}
              <FlatList
                data={items}
                keyExtractor={(it, i) => String(it.id ?? i)}
                renderItem={({ item }) => (
                  <View style={s.row}>
                    <ColumnCell width={150} text={String(item.investorId)} />
                    <ColumnCell width={200} text={String(item.projectId)} />
                    <ColumnCell width={120} text={fmtMt(item.investedAmount)} />
                    <ColumnCell width={120} child={<StatusChip status={item.actualProfit > 0 ? 'Completed' : 'Active'} />} />
                    {/* <ColumnCell width={150} text={item.transactionRef} isMonospace /> */}
                  </View>
                )}
                ItemSeparatorComponent={() => <View style={{ height: 8 }} />}
                scrollEnabled={false}
              />
            </View>
          </ScrollView>
        )}
      </View>
    </View>
  );
};

/* ===== componentes ===== */

const ColumnHeader: React.FC<{ title: string; width: number }> = ({ title, width }) => (
  <View style={[s.colHeader, { width }]}>
    <Text style={s.colHeaderTxt}>{title}</Text>
  </View>
);

const ColumnCell: React.FC<{ width: number; text?: string; child?: React.ReactNode; isMonospace?: boolean }> = ({
  width,
  text,
  child,
  isMonospace,
}) => (
  <View style={[s.colCell, { width }]}>
    {child ?? <Text style={{ fontSize: 13, fontFamily: isMonospace ? 'monospace' as any : undefined }}>{text ?? ''}</Text>}
  </View>
);

const StatusChip: React.FC<{ status: 'Completed' | 'Active' | 'Pending' | 'Failed' | string }> = ({ status }) => {
  const map = {
    Completed: { c: '#16A34A', t: 'Concluído' },
    Active: { c: '#2563EB', t: 'Ativo' },
    Pending: { c: '#EA580C', t: 'Pendente' },
    Failed: { c: '#DC2626', t: 'Falhou' },
  } as const;
  const { c, t } = (map as any)[status] ?? { c: '#6B7280', t: status };
  return (
    <View style={[s.chip, { backgroundColor: hexWithAlpha(c, 0.15) }]}>
      <Text style={{ color: c, fontWeight: '600', fontSize: 12 }}>{t}</Text>
    </View>
  );
};

/* ===== helpers ===== */

function fmtMt(v: number) {
  const s = v.toFixed(2);
  const [intp, frac] = s.split('.');
  let out = '';
  let c = 0;
  for (let i = intp.length - 1; i >= 0; i--) {
    out = intp[i] + out;
    c++;
    if (c === 3 && i !== 0) {
      out = '.' + out;
      c = 0;
    }
  }
  return `MT ${out},${frac}`;
}
function hexWithAlpha(hex: string, alpha: number) {
  const a = Math.round(alpha * 255).toString(16).padStart(2, '0');
  return `${hex}${a}`;
}

/* ===== estilos ===== */

const s = StyleSheet.create({
  appbar: {
    height: 56,
    backgroundColor: '#fff',
    justifyContent: 'center',
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  appbarTitle: { color: '#111827', fontWeight: '700', fontSize: 18 },

  btn: {
    minHeight: 44,
    borderRadius: 8,
    paddingHorizontal: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  btnTxt: { fontWeight: '700' },

  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },

  headerRow: {
    flexDirection: 'row',
    backgroundColor: '#EFEFEF',
    borderTopWidth: 1,
    borderBottomWidth: 1,
    borderColor: '#D1D5DB',
  },
  row: { flexDirection: 'row' },

  colHeader: { paddingVertical: 12, paddingHorizontal: 8, borderRightWidth: 1, borderRightColor: '#D1D5DB' },
  colHeaderTxt: { fontWeight: '700', fontSize: 14 },

  colCell: { paddingVertical: 12, paddingHorizontal: 8, borderRightWidth: 1, borderRightColor: '#D1D5DB' },

  chip: { paddingHorizontal: 8, paddingVertical: 6, borderRadius: 20, alignSelf: 'flex-start' },
});

export default InvestmentManagementView;
