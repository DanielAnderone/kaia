// src/screens/admin/InvestorsView.tsx
import React, { useEffect, useMemo, useState } from 'react';
import {
  View,
  Text,
  ActivityIndicator,
  FlatList,
  RefreshControl,
  StyleSheet,
} from 'react-native';

// ajuste caminhos
import type { Investor } from '../../models/model';
import { InvestorService } from '../../service/investor.service';

const kycColor = (status?: string) => {
  switch (status) {
    case 'Approved':
      return '#1B5E20';
    case 'Pending':
      return '#E65100';
    case 'Rejected':
      return '#B71C1C';
    default:
      return '#9E9E9E';
  }
};

const InvestorsView: React.FC = () => {
  const svc = useMemo(() => new InvestorService(), []);
  const [investors, setInvestors] = useState<Investor[]>([]);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setErr(null);
    try {
      const list = await svc.getAll();
      setInvestors(list);
    } catch (e: any) {
      setErr(String(e?.message || e));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (loading && investors.length === 0) {
    return (
      <View style={s.center}>
        <ActivityIndicator />
      </View>
    );
  }

  if (err) {
    return (
      <View style={s.center}>
        <Text>Erro: {err}</Text>
      </View>
    );
  }

  if (investors.length === 0) {
    return (
      <View style={s.center}>
        <Text>Nenhum investidor encontrado</Text>
      </View>
    );
  }

  return (
    <FlatList
      data={investors}
      keyExtractor={(it, idx) => String(it.id ?? idx)}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={load} />}
      contentContainerStyle={{ padding: 16 }}
      renderItem={({ item }) => (
        <View style={s.card}>
          <Text style={s.title}>{item.name}</Text>
          <View style={{ height: 6 }} />
          <Text style={s.sub}>Email: {item.name}</Text>
          <Text style={s.sub}>Projeto: {item.identityCard || 'Não informado'} </Text>

          {/* Badge de KYC se tiver status no payload; aqui opcional */}
          {Boolean((item as any).status) && (
            <View style={[s.badge, { borderColor: kycColor((item as any).status) }]}>
              <Text style={[s.badgeText, { color: kycColor((item as any).status) }]}>
                {(item as any).status}
              </Text>
            </View>
          )}
        </View>
      )}
    />
  );
};

const s = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 12,
    marginVertical: 8,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  title: { fontWeight: '700', color: '#111827' },
  sub: { color: '#6B7280', fontSize: 13 },
  badge: {
    alignSelf: 'flex-start',
    marginTop: 6,
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 12,
    borderWidth: 1,
  },
  badgeText: { fontWeight: '700', fontSize: 12 },
});

export default InvestorsView;
