// src/screens/admin/AdminProfileScreen.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  Image,
  TextInput,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';

const primary = '#386641';

const AdminProfileScreen: React.FC = () => {
  const nav = useNavigation<any>();
  const [editing, setEditing] = useState(false);

  const [nome, setNome] = useState('João Silva');
  const [tel, setTel] = useState('+258 84 123 4567');
  const [dob, setDob] = useState('12 de Maio de 1985');
  const [nuit, setNuit] = useState('123456789');

  const salvar = () => {
    // integre com sua API aqui
    setEditing(false);
  };

  return (
    <View style={{ flex: 1 }}>
      {/* AppBar */}
      <View style={s.appbar}>
        <TouchableOpacity onPress={() => nav.goBack()}>
          <Text style={s.appbarIcon}>‹</Text>
        </TouchableOpacity>
        <Text style={s.appbarTitle}>Perfil do Administrador</Text>
        <TouchableOpacity onPress={() => nav.reset({ index: 0, routes: [{ name: 'Login' }] })}>
          <Text style={s.appbarAction}>Sair</Text>
        </TouchableOpacity>
      </View>

      <ScrollView contentContainerStyle={{ padding: 16 }}>
        <View style={{ alignItems: 'center' }}>
          <Image
            source={{ uri: 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png' }}
            style={s.avatar}
          />
          <View style={{ height: 16 }} />
          <Text style={s.name}>{nome}</Text>
          <View style={{ height: 16 }} />
          <TouchableOpacity style={s.editBtn} onPress={() => setEditing(e => !e)}>
            <Text style={s.editBtnTxt}>{editing ? 'Editar desligado' : 'Editar Perfil'}</Text>
          </TouchableOpacity>
        </View>

        <View style={{ height: 32 }} />

        <Field label="Nome Completo" value={nome} onChangeText={setNome} editable={editing} />
        <Spacer />
        <Field label="Número de Telefone" value={tel} onChangeText={setTel} editable={editing} keyboardType="phone-pad" />
        <Spacer />
        <Field label="Data de Nascimento" value={dob} onChangeText={setDob} editable={editing} />
        <Spacer />
        <Field label="Nuit" value={nuit} onChangeText={setNuit} editable={editing} keyboardType="number-pad" />

        <View style={{ height: 32 }} />

        <View style={{ flexDirection: 'row' }}>
          <View style={{ flex: 1 }}>
            <TouchableOpacity style={s.saveBtn} onPress={salvar} disabled={!editing}>
              <Text style={s.saveBtnTxt}>Guardar Alterações</Text>
            </TouchableOpacity>
          </View>
          <View style={{ width: 16 }} />
          <View style={{ flex: 1 }}>
            <TouchableOpacity style={s.cancelBtn} onPress={() => nav.goBack()}>
              <Text style={s.cancelBtnTxt}>Cancelar</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </View>
  );
};

const Field: React.FC<{
  label: string;
  value: string;
  onChangeText: (t: string) => void;
  editable?: boolean;
  keyboardType?: 'default' | 'number-pad' | 'phone-pad' | 'email-address';
}> = ({ label, value, onChangeText, editable = true, keyboardType = 'default' }) => (
  <View>
    <Text style={s.label}>{label}</Text>
    <TextInput
      value={value}
      onChangeText={onChangeText}
      editable={editable}
      keyboardType={keyboardType}
      style={[s.input, !editable && s.inputDisabled]}
      placeholder={label}
      placeholderTextColor="#9CA3AF"
    />
  </View>
);

const Spacer = () => <View style={{ height: 16 }} />;

const s = StyleSheet.create({
  appbar: {
    height: 56,
    backgroundColor: primary,
    paddingHorizontal: 12,
    flexDirection: 'row',
    alignItems: 'center',
  },
  appbarIcon: { color: '#fff', fontSize: 20, width: 28, textAlign: 'center' },
  appbarTitle: { color: '#fff', fontWeight: '700', fontSize: 18, flex: 1, textAlign: 'center' },
  appbarAction: { color: '#fff', fontWeight: '700' },

  avatar: { width: 128, height: 128, borderRadius: 64 },
  name: { fontSize: 22, fontWeight: '700', color: '#111' },

  editBtn: {
    backgroundColor: primary,
    borderRadius: 16,
    minHeight: 48,
    paddingHorizontal: 16,
    alignItems: 'center',
    justifyContent: 'center',
    alignSelf: 'stretch',
  },
  editBtnTxt: { color: '#fff', fontSize: 16, fontWeight: '700' },

  label: { fontSize: 16, fontWeight: '600', color: '#111', marginBottom: 8 },
  input: {
    height: 48,
    borderRadius: 16,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    paddingHorizontal: 12,
    color: '#111',
  },
  inputDisabled: { backgroundColor: '#E5E7EB' },

  saveBtn: {
    backgroundColor: primary,
    borderRadius: 16,
    minHeight: 48,
    alignItems: 'center',
    justifyContent: 'center',
  },
  saveBtnTxt: { color: '#fff', fontWeight: '700' },

  cancelBtn: {
    borderRadius: 16,
    minHeight: 48,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: primary,
  },
  cancelBtnTxt: { color: primary, fontWeight: '700' },
});

export default AdminProfileScreen;
