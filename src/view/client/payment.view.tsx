// src/view/client/payment.view.tsx
import React, { useMemo, useState } from 'react';
import {
  View,
  Text,
  TextInput,
  ScrollView,
  ActivityIndicator,
  TouchableOpacity,
  Modal,
  Pressable,
  Alert,
  StyleSheet,
} from 'react-native';
import { useRoute, RouteProp, useNavigation } from '@react-navigation/native';

// ajuste estes imports conforme sua árvore
import { TransactionService } from '../../service/transactions.service';
import type { Project, Investor, Transaction } from '../../models/model';

type RootParams = {
  InvestorPayments:
    | { investor?: Investor; project?: Project; phone?: string }
    | undefined;
};

const PRIMARY = '#169C1D';

const money = (v: number) => {
  const s = v.toFixed(2);
  const [i, f] = s.split('.');
  const buf: string[] = [];
  let c = 0;
  for (let k = i.length - 1; k >= 0; k--) {
    buf.push(i[k]);
    c++;
    if (c === 3 && k !== 0) {
      buf.push('.');
      c = 0;
    }
  }
  return `MT ${buf.reverse().join('')},${f}`;
};

const fmtDate = (d: Date, withTime = false) => {
  const dd = String(d.getDate()).padStart(2, '0');
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const yyyy = String(d.getFullYear());
  if (!withTime) return `${dd}/${mm}/${yyyy}`;
  const hh = String(d.getHours()).padStart(2, '0');
  const mi = String(d.getMinutes()).padStart(2, '0');
  const ss = String(d.getSeconds()).padStart(2, '0');
  return `${dd}/${mm}/${yyyy} ${hh}:${mi}:${ss}`;
};

export default function PaymentView() {
  const navigation = useNavigation();
  const route = useRoute<RouteProp<RootParams, 'InvestorPayments'>>();

  const investor = route.params?.investor;
  const project = route.params?.project;
  const phoneArg = route.params?.phone;

  const payerFromId = investor?.id ?? investor?.userId ?? undefined;
  const payerToId = project?.ownerId ?? undefined;
  const phone = phoneArg ?? investor?.phone ?? '';

  const [amount, setAmount] = useState('');
  const [loading, setLoading] = useState(false);

  const [receipt, setReceipt] = useState<{
    id: string;
    phone: string;
    valor: number;
    taxa: string;
    total: string;
    criadoEm: Date;
  } | null>(null);

  const canSubmit = useMemo(() => {
    const v = Number(String(amount).replace(',', '.'));
    return !!phone && payerFromId != null && payerToId != null && v > 0;
  }, [amount, phone, payerFromId, payerToId]);

  const svc = useMemo(() => new TransactionService(), []);

  const submit = async () => {
    if (!canSubmit) {
      Alert.alert('Dados incompletos', 'Preencha os campos corretamente.');
      return;
    }
    const value = Number(String(amount).replace(',', '.'));
    setLoading(true);
    try {
      const tx: Transaction = {
        id: null,
        paymentId: 1, // ou deixe o backend atribuir
        investorId: payerFromId as number,
        payerAccount: phone,
        gatewayRef: '',
        transactionId: String(Date.now()),
        amount: value,
      };

      const resp = await svc.createTransaction(tx); // implemente na sua service TS

      setReceipt({
        id: String((resp as any)?.id ?? Date.now()),
        phone,
        valor: value,
        taxa: '0.00',
        total: value.toFixed(2),
        criadoEm: new Date(),
      });
      setAmount('');
    } catch (e: any) {
      Alert.alert('Erro', String(e?.message ?? e));
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={[styles.screen]}>
      <View style={[styles.appbar]}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.appbarBack}>{'<'} </Text>
        </TouchableOpacity>
        <Text style={styles.appbarTitle}>Pagamentos</Text>
        <View style={{ width: 24 }} />
      </View>

      <ScrollView contentContainerStyle={{ padding: 16 }}>
        {/* Resumo */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Resumo</Text>
          <KV k="Telefone do investidor" v={phone || '—'} />
          <KV k="De (payer_from_id)" v={payerFromId?.toString() ?? '—'} />
          <KV k="Para (payer_to_id)" v={payerToId?.toString() ?? '—'} />
          <KV k="Moeda" v="MT" />
          <KV k="Processador" v="Backend KAIA" />
        </View>

        {/* Form */}
        <View style={[styles.card, { marginTop: 12 }]}>
          <View style={{ marginBottom: 10 }}>
            <Text style={styles.inputLabel}>Telefone</Text>
            <View style={[styles.input, { opacity: 0.7 }]}>
              <Text>{phone || '—'}</Text>
            </View>
          </View>

          <View>
            <Text style={styles.inputLabel}>Valor (MT)</Text>
            <View style={styles.input}>
              <TextInput
                keyboardType="decimal-pad"
                value={amount}
                onChangeText={setAmount}
                placeholder="0,00"
                placeholderTextColor="#9CA3AF"
                style={{ flex: 1 }}
              />
            </View>
          </View>
        </View>

        <TouchableOpacity
          disabled={loading || !canSubmit}
          onPress={submit}
          style={[
            styles.button,
            { opacity: loading || !canSubmit ? 0.6 : 1, marginTop: 16 },
          ]}
        >
          {loading ? (
            <ActivityIndicator />
          ) : (
            <Text style={styles.buttonText}>Confirmar pagamento</Text>
          )}
        </TouchableOpacity>
      </ScrollView>

      {/* Recibo */}
      <Modal visible={!!receipt} transparent animationType="slide" onRequestClose={() => setReceipt(null)}>
        <View style={styles.modalWrap}>
          <View style={styles.modalSheet}>
            <View style={styles.modalHandle} />
            <Text style={styles.modalTitle}>Recibo</Text>
            <View style={{ height: 8 }} />
            {receipt && (
              <>
                <KV k="ID" v={receipt.id} />
                <KV k="Telefone" v={receipt.phone || '—'} />
                <KV k="Valor" v={money(receipt.valor)} />
                <KV k="Taxa" v={money(Number(receipt.taxa))} />
                <View style={styles.divider} />
                <KV k="Total" v={money(Number(receipt.total))} />
                <View style={styles.divider} />
                <KV k="Criado em" v={fmtDate(receipt.criadoEm, true)} />
              </>
            )}
            <View style={{ height: 14 }} />
            <View style={{ flexDirection: 'row', gap: 10 }}>
              <Pressable style={[styles.pillBtn]} onPress={() => { /* copiar ID */ }}>
                <Text style={[styles.pillBtnText]}>Copiar ID</Text>
              </Pressable>
              <Pressable style={[styles.solidBtn]} onPress={() => { /* share */ }}>
                <Text style={[styles.solidBtnText]}>Partilhar</Text>
              </Pressable>
            </View>
            <View style={{ height: 14 }} />
            <TouchableOpacity onPress={() => setReceipt(null)} style={[styles.button, { backgroundColor: '#111827' }]}>
              <Text style={styles.buttonText}>Fechar</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </View>
  );
}

function KV({ k, v }: { k: string; v: string }) {
  return (
    <View style={styles.kvRow}>
      <Text style={styles.kvKey}>{k}</Text>
      <Text numberOfLines={1} style={styles.kvVal}>
        {v}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: '#F6F8F6' },
  appbar: {
    height: 52,
    paddingHorizontal: 8,
    backgroundColor: '#F6F8F6',
    flexDirection: 'row',
    alignItems: 'center',
  },
  appbarBack: { color: '#111827', fontSize: 18, paddingHorizontal: 8 },
  appbarTitle: { flex: 1, textAlign: 'center', fontWeight: '700', color: '#111827' },

  card: { backgroundColor: '#fff', borderRadius: 12, padding: 14 },
  cardTitle: { fontWeight: '800', color: '#111827' },

  inputLabel: { color: '#111827', marginBottom: 6, fontWeight: '600' },
  input: {
    minHeight: 44,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 10,
    paddingHorizontal: 12,
    justifyContent: 'center',
    backgroundColor: '#fff',
  },

  button: {
    height: 48,
    borderRadius: 12,
    backgroundColor: PRIMARY,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: PRIMARY,
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  buttonText: { color: '#fff', fontWeight: '700' },

  kvRow: { flexDirection: 'row', justifyContent: 'space-between', marginVertical: 4 },
  kvKey: { color: '#6B7280', fontSize: 13 },
  kvVal: { color: '#111827', marginLeft: 8, maxWidth: '60%', textAlign: 'right' },

  modalWrap: { flex: 1, backgroundColor: 'rgba(0,0,0,0.25)', justifyContent: 'flex-end' },
  modalSheet: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    paddingHorizontal: 16,
    paddingTop: 10,
    paddingBottom: 20,
  },
  modalHandle: {
    alignSelf: 'center',
    width: 40,
    height: 5,
    borderRadius: 999,
    backgroundColor: '#D1D5DB',
    marginBottom: 8,
  },
  modalTitle: { fontWeight: '800', fontSize: 16, color: '#111827' },
  divider: { height: 1, backgroundColor: '#E5E7EB', marginVertical: 8 },

  pillBtn: {
    flex: 1,
    height: 44,
    borderRadius: 24,
    borderWidth: 1,
    borderColor: PRIMARY,
    alignItems: 'center',
    justifyContent: 'center',
  },
  pillBtnText: { color: PRIMARY, fontWeight: '700' },
  solidBtn: {
    flex: 1,
    height: 44,
    borderRadius: 24,
    backgroundColor: PRIMARY,
    alignItems: 'center',
    justifyContent: 'center',
  },
  solidBtnText: { color: '#fff', fontWeight: '700' },
});
