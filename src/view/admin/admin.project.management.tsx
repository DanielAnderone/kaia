// src/screens/admin/AdminProjectManagementView.tsx
import React, { useEffect, useMemo, useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  FlatList,
  Image,
  Alert,
} from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { useNavigation } from '@react-navigation/native';
import { type Project } from '../../models/model';
import { ProjectService } from '../../service/project.service';

const primary = '#169C1D';

const riskOptions = ['Baixo', 'Médio', 'Alto'];
const statusOptions = ['Planejado', 'Em andamento', 'Concluído', 'Pausado'];

const AdminProjectManagementView: React.FC = () => {
  const nav = useNavigation<any>();
  const svc = useMemo(() => new ProjectService(), []);
  const [projects, setProjects] = useState<Project[]>([]);
  const [loadingList, setLoadingList] = useState(true);

  // form state
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [projectBudget, setProjectBudget] = useState('');   // orçamento (MT)
  const [roi, setRoi] = useState('');                       // ROI (%)
  const [totalBudget, setTotalBudget] = useState('');       // total (MT)
  const [risk, setRisk] = useState<string | null>(null);
  const [status, setStatus] = useState<string | null>(null);
  const [startDate, setStartDate] = useState<string | null>(null); // YYYY-MM-DD
  const [endDate, setEndDate] = useState<string | null>(null);
  const [image, setImage] = useState<ImagePicker.ImagePickerAsset | null>(null);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    load();
  }, []);

  const load = async () => {
    setLoadingList(true);
    try {
      const data = await svc.listProjects();
      setProjects(data);
    } catch (e: any) {
      Alert.alert('Erro', String(e?.message || e));
    } finally {
      setLoadingList(false);
    }
  };

  const pickImage = async () => {
    const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('Permissão', 'Permita acesso às fotos.');
      return;
    }
    const res = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsMultipleSelection: false,
      quality: 0.8,
    });
    if (!res.canceled) setImage(res.assets[0]);
  };

  const parsePos = (s: string) => {
    const n = Number(String(s).replace(',', '.'));
    return Number.isFinite(n) && n >= 0 ? n : -1;
  };

  const addProject = async () => {
    if (!name.trim() || !risk || !status || !startDate || !endDate) {
      Alert.alert('Atenção', 'Preencha todos os campos obrigatórios.');
      return;
    }
    if (endDate < startDate) {
      Alert.alert('Atenção', 'Data fim deve ser posterior à data início.');
      return;
    }

    const tb = parsePos(totalBudget);
    const pb = parsePos(projectBudget);
    const r = parsePos(roi);
    if (tb < 0 || pb < 0 || r < 0) {
      Alert.alert('Atenção', 'Valores numéricos devem ser positivos.');
      return;
    }

    // mapeamento fiel ao seu modelo
    const p: Project = {
      id: null,
      description: description.trim(),
      totalProfit: tb,
      minimumInvestment: r,
      riskLevel: risk!,
      status: status!,
      startDate: startDate ? new Date(startDate) : null,
      endDate: endDate ? new Date(endDate) : null,
      profitabilityPercent: 0,
      mediaPath: '',
    };

    setSaving(true);
    try {
      let created: Project;
      if (image?.uri) {
        created = await svc.addProjectWithImage(p, image.uri);
      } else {
        created = await svc.addProject(p);
      }
      clearForm();
      await load();
      Alert.alert('Sucesso', 'Projeto salvo com sucesso.');
    } catch (e: any) {
      Alert.alert('Erro', String(e?.message || e));
    } finally {
      setSaving(false);
    }
  };

  const delProject = async (id?: number | null) => {
    if (id == null) return;
    try {
      await svc.deleteProject(id);
      await load();
      Alert.alert('Info', 'Projeto removido.');
    } catch (e: any) {
      Alert.alert('Erro', String(e?.message || e));
    }
  };

  const clearForm = () => {
    setName('');
    setDescription('');
    setProjectBudget('');
    setRoi('');
    setTotalBudget('');
    setRisk(null);
    setStatus(null);
    setStartDate(null);
    setEndDate(null);
    setImage(null);
  };

  return (
    <View style={{ flex: 1, backgroundColor: '#F5F5F5' }}>
      {/* AppBar */}
      <View style={s.appbar}>
        <TouchableOpacity onPress={() => nav.goBack()}>
          <Text style={s.appbarIcon}>‹</Text>
        </TouchableOpacity>
        <Text style={s.appbarTitle}>Gestão de Projetos</Text>
        <View style={{ width: 28 }} />
      </View>

      <ScrollView contentContainerStyle={{ padding: 16 }}>
        {/* Formulário */}
        <View style={s.card}>
          <Text style={s.cardTitle}>Novo Projeto</Text>

          <Field label="Nome do Projeto" value={name} onChangeText={setName} />
          <Gap />

          <Label>Descrição</Label>
          <TextInput
            value={description}
            onChangeText={setDescription}
            style={[s.input, { height: 100, textAlignVertical: 'top' }]}
            multiline
            placeholder="Descreva o projeto"
            placeholderTextColor="#9CA3AF"
          />
          <Gap />

          <Row>
            <Col>
              <Field
                label="Orçamento (MT)"
                value={projectBudget}
                onChangeText={setProjectBudget}
                keyboardType="numeric"
              />
            </Col>
            <Spacer />
            <Col>
              <Field
                label="ROI (%)"
                value={roi}
                onChangeText={setRoi}
                keyboardType="numeric"
              />
            </Col>
          </Row>
          <Gap />

          <Field
            label="Orçamento Total (MT)"
            value={totalBudget}
            onChangeText={setTotalBudget}
            keyboardType="numeric"
          />
          <Gap />

          <Row>
            <Col>
              <PickerLike
                label="Risco"
                value={risk}
                options={riskOptions}
                onSelect={setRisk}
              />
            </Col>
            <Spacer />
            <Col>
              <PickerLike
                label="Status"
                value={status}
                options={statusOptions}
                onSelect={setStatus}
              />
            </Col>
          </Row>
          <Gap />

          <Row>
            <Col>
              <Field
                label="Data Início (YYYY-MM-DD)"
                value={startDate ?? ''}
                onChangeText={setStartDate}
                placeholder="YYYY-MM-DD"
              />
            </Col>
            <Spacer />
            <Col>
              <Field
                label="Data Fim (YYYY-MM-DD)"
                value={endDate ?? ''}
                onChangeText={setEndDate}
                placeholder="YYYY-MM-DD"
              />
            </Col>
          </Row>
          <Gap />

          <Row>
            <TouchableOpacity onPress={pickImage} style={[s.btn, { backgroundColor: '#4B5563' }]}>
              <Text style={s.btnTxt}>Selecionar Imagem</Text>
            </TouchableOpacity>
            {!!image?.uri && (
              <Image
                source={{ uri: image.uri }}
                style={{ width: 60, height: 60, borderRadius: 8, marginLeft: 8 }}
              />
            )}
          </Row>

          <Gap />

          <TouchableOpacity
            style={[s.btn, { backgroundColor: primary }]}
            onPress={addProject}
            disabled={saving}
          >
            <Text style={[s.btnTxt, { color: '#fff' }]}>{saving ? 'Salvando…' : 'Salvar Projeto'}</Text>
          </TouchableOpacity>
        </View>

        <Gap size={24} />

        {/* Lista */}
        {loadingList ? (
          <Text style={{ color: '#6B7280' }}>Carregando…</Text>
        ) : projects.length === 0 ? (
          <Text style={{ color: '#6B7280' }}>Nenhum projeto cadastrado.</Text>
        ) : (
          <FlatList
            data={projects}
            keyExtractor={(item, i) => String(item.id ?? i)}
            renderItem={({ item }) => <ProjectCard p={item} onDelete={() => delProject(item.id)} />}
            ItemSeparatorComponent={() => <Gap size={10} />}
            scrollEnabled={false}
          />
        )}
      </ScrollView>
    </View>
  );
};

/* ===== componentes ===== */

const Field: React.FC<{
  label: string;
  value: string;
  onChangeText: (t: string) => void;
  placeholder?: string;
  keyboardType?: 'default' | 'numeric' | 'number-pad';
}> = ({ label, value, onChangeText, placeholder, keyboardType = 'default' }) => (
  <View>
    <Label>{label}</Label>
    <TextInput
      value={value}
      onChangeText={onChangeText}
      placeholder={placeholder ?? label}
      placeholderTextColor="#9CA3AF"
      keyboardType={keyboardType}
      style={s.input}
    />
  </View>
);

const PickerLike: React.FC<{
  label: string;
  value: string | null;
  options: string[];
  onSelect: (v: string) => void;
}> = ({ label, value, options, onSelect }) => (
  <View>
    <Label>{label}</Label>
    <View style={s.pickerBox}>
      <Text style={{ color: value ? '#111' : '#9CA3AF' }}>{value ?? 'Selecione'}</Text>
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', marginTop: 8, gap: 8 }}>
        {options.map((o) => (
          <TouchableOpacity key={o} onPress={() => onSelect(o)} style={[s.pill, value === o && s.pillSel]}>
            <Text style={[s.pillTxt, value === o && s.pillTxtSel]}>{o}</Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  </View>
);

const ProjectCard: React.FC<{ p: Project; onDelete: () => void }> = ({ p, onDelete }) => {
  const statusColor = (s: string | null | undefined) => {
    if (s === 'Em andamento') return primary;
    if (s === 'Concluído') return '#6B7280';
    if (s === 'Pausado') return '#EA580C';
    return '#A16207';
  };
  return (
    <View style={s.cardItem}>
      {p.mediaPath ? (
        <Image source={{ uri: String(p.mediaPath) }} style={s.cardImg} />
      ) : (
        <View style={[s.cardImg, { backgroundColor: '#F3F4F6', alignItems: 'center', justifyContent: 'center' }]}>
          <Text style={{ color: '#9CA3AF' }}>Sem imagem</Text>
        </View>
      )}

      <View style={{ height: 12 }} />

      <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
        <Text style={s.cardTitleSm}>#{p.id ?? '-'}</Text>
        <View style={[s.badge, { backgroundColor: hexWithAlpha(statusColor(p.status), 0.12) }]}>
          <Text style={{ color: statusColor(p.status), fontWeight: '700' }}>{p.status ?? '-'}</Text>
        </View>
      </View>

      <View style={{ height: 8 }} />
      <Text style={{ color: '#111' }}>{p.description ?? '-'}</Text>

      <View style={{ height: 12 }} />

      <View style={s.grid2}>
        <SmallInfo label="Budget & ROI" value={`${fmtMt(p.totalProfit ?? 0)} / ${(p.profitabilityPercent ?? 0).toFixed(1)}%`} />
        <SmallInfo label="Risco" value={p.riskLevel ?? '-'} valueColor={p.riskLevel === 'Baixo' ? '#16A34A' : p.riskLevel === 'Médio' ? '#EA580C' : '#DC2626'} />
        <SmallInfo label="Duração" value={`${fmtDDMMYYYY(p.startDate)} • ${fmtDDMMYYYY(p.endDate)}`} />
        <SmallInfo label="Total" value={fmtMt(p.totalProfit ?? 0)} />
      </View>

      <View style={{ height: 8 }} />

      <View style={{ alignItems: 'flex-end' }}>
        <TouchableOpacity onPress={onDelete}>
          <Text style={{ color: '#DC2626', fontWeight: '700' }}>Excluir</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const SmallInfo: React.FC<{ label: string; value: string; valueColor?: string }> = ({ label, value, valueColor }) => (
  <View>
    <Text style={{ fontSize: 12, color: '#6B7280' }}>{label}</Text>
    <View style={{ height: 4 }} />
    <Text style={{ fontSize: 14, fontWeight: '700', color: valueColor ?? '#111712' }} numberOfLines={1}>
      {value}
    </Text>
  </View>
);

const Label: React.FC<React.PropsWithChildren> = ({ children }) => (
  <Text style={s.label}>{children}</Text>
);

const Row: React.FC<React.PropsWithChildren> = ({ children }) => (
  <View style={{ flexDirection: 'row', alignItems: 'center' }}>{children}</View>
);
const Col: React.FC<React.PropsWithChildren> = ({ children }) => <View style={{ flex: 1 }}>{children}</View>;
const Spacer = () => <View style={{ width: 12 }} />;
const Gap: React.FC<{ size?: number }> = ({ size = 12 }) => <View style={{ height: size }} />;

/* ===== helpers ===== */

function fmtMt(v: number) {
  const s = v.toFixed(2);
  const [intp, frac] = s.split('.');
  let out = '';
  let c = 0;
  for (let i = intp.length - 1; i >= 0; i--) {
    out = intp[i] + out;
    c++;
    if (c === 3 && i !== 0) { out = '.' + out; c = 0; }
  }
  return `MT ${out},${frac}`;
}
function fmtDDMMYYYY(d?: Date | string | null) {
  if (!d) return '-';
  const dt = typeof d === 'string' ? new Date(d) : d;
  if (Number.isNaN(dt.getTime())) return '-';
  const dd = String(dt.getDate()).padStart(2, '0');
  const mm = String(dt.getMonth() + 1).padStart(2, '0');
  const yy = String(dt.getFullYear());
  return `${dd}/${mm}/${yy}`;
}
function hexWithAlpha(hex: string, alpha: number) {
  const a = Math.round(alpha * 255).toString(16).padStart(2, '0');
  return `${hex}${a}`;
}

/* ===== estilos ===== */

const s = StyleSheet.create({
  appbar: {
    height: 56, backgroundColor: primary, paddingHorizontal: 12,
    flexDirection: 'row', alignItems: 'center',
  },
  appbarIcon: { color: '#fff', fontSize: 20, width: 28, textAlign: 'center' },
  appbarTitle: { color: '#fff', fontWeight: '700', fontSize: 18, flex: 1, textAlign: 'center' },

  card: {
    backgroundColor: '#fff', borderRadius: 16, padding: 16,
    shadowColor: '#000', shadowOpacity: 0.06, shadowRadius: 10, elevation: 2,
  },
  cardTitle: { fontSize: 20, fontWeight: '700', color: '#111' },

  label: { fontSize: 13, fontWeight: '700', color: '#374151', marginBottom: 6 },
  input: {
    height: 44, borderRadius: 12, borderWidth: 1, borderColor: '#E5E7EB',
    backgroundColor: '#fff', paddingHorizontal: 12, color: '#111',
  },

  pickerBox: { borderWidth: 1, borderColor: '#E5E7EB', borderRadius: 12, padding: 12, backgroundColor: '#fff' },
  pill: { paddingHorizontal: 10, paddingVertical: 6, borderRadius: 999, borderWidth: 1, borderColor: '#D1D5DB' },
  pillSel: { backgroundColor: hexWithAlpha(primary, 0.12), borderColor: primary },
  pillTxt: { color: '#374151', fontWeight: '600' },
  pillTxtSel: { color: primary },

  btn: {
    minHeight: 44, borderRadius: 12, paddingHorizontal: 16,
    alignItems: 'center', justifyContent: 'center',
  },
  btnTxt: { fontWeight: '700', color: '#fff' },

  cardItem: {
    backgroundColor: '#fff', borderRadius: 12, padding: 14,
    borderWidth: 1, borderColor: '#E5E7EB', shadowColor: '#000',
    shadowOpacity: 0.06, shadowRadius: 6, elevation: 1,
  },
  cardImg: { height: 160, width: '100%', borderRadius: 12, resizeMode: 'cover' },
  cardTitleSm: { fontSize: 18, fontWeight: '700', color: '#111712' },
  badge: { paddingHorizontal: 10, paddingVertical: 5, borderRadius: 20 },

  grid2: {
    flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between',
  },
});

export default AdminProjectManagementView;
