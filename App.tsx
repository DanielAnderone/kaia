// App.tsx
import 'react-native-gesture-handler';
import 'react-native-reanimated';
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

// IMPORTA TUAS TELAS RN (ajusta caminhos):
import LoginView from '../kaia_mult/src/view/login.view';
import SignUpView from '../kaia_mult/src/view/signup.view';
import ProjectsView from '../../kaia/kaia_mult/src/view/client/project.view';
import PaymentView from '../../kaia/kaia_mult/src/view/client/payment.view';
import TransactionsView from '../../kaia/kaia_mult/src/view/client/transactions.view';
import AccountView from '../../kaia/kaia_mult/src/view/client/profile.view';
import InvestmentsView from '../../kaia/kaia_mult/src/view/client/investiment.view';

import AdminDashboardView from '../../kaia/kaia_mult/src/view/admin/admin.dasbord';
import AdminProfileScreen from '../../kaia/kaia_mult/src/view/admin/admin.profile';
import AdminProjectManagementView from '../../kaia/kaia_mult/src/view/admin/admin.project.management';
import AdminSettingsView from '../../kaia/kaia_mult/src/view/admin/admin.settings';
import InvestmentManagementView from '../../kaia/kaia_mult/src/view/admin/admin.investiment.management';
import InvestorsView from '../../kaia/kaia_mult/src/view/client/investors.view';

// Opcional: tela simples para "forgot"
import { View, Text } from 'react-native';
const Forgot = () => (
  <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
    <Text>Recuperar senha (em breve)</Text>
  </View>
);

// Mapa de rotas equivalente às tuas rotas Flutter
export type RootStackParamList = {
  Login: undefined;                 // '/'
  SignUp: { apiBaseUrl?: string; buttonColor?: string } | undefined; // '/signup'
  InvestorProjects: undefined;      // '/investor/projects'
  InvestorPayments: undefined;      // '/investor/payments'
  InvestorTransactions: undefined;  // '/investor/transactions'
  InvestorProfile: undefined;       // '/investor/profile'
  InvestorInvestments: undefined;   // '/investor/investiments'
  AdminInvestments: undefined;      // '/admin/investiments'
  AdminDashboard: undefined;        // '/admin/dashboard'
  AdminProjectManagement: undefined;// '/admin/pgmanagement'
  AdminInvestors: undefined;        // '/admin/investors'
  AdminProfile: undefined;          // '/admin/profile'
  AdminSettings: undefined;         // '/admin/settings'
  Forgot: undefined;                // '/forgot'
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Login" screenOptions={{ headerShown: false }}>
        {/* '/' */}
        <Stack.Screen name="Login" component={LoginView} />

        {/* '/signup' */}
        <Stack.Screen name="SignUp" component={SignUpView} />

        {/* Investor */}
        {/* <Stack.Screen name="InvestorProjects" component={ProjectsView} />
        <Stack.Screen name="InvestorPayments" component={PaymentView} />
        <Stack.Screen name="InvestorTransactions" component={TransactionsView} />
        <Stack.Screen name="InvestorProfile" component={AccountView} />
        <Stack.Screen name="InvestorInvestments" component={InvestmentsView} /> */}

        {/* Admin */}
        {/* <Stack.Screen name="AdminInvestments" component={InvestmentManagementView} />
        <Stack.Screen name="AdminDashboard" component={AdminDashboardView} />
        <Stack.Screen name="AdminProjectManagement" component={AdminProjectManagementView} />
        <Stack.Screen name="AdminInvestors" component={InvestorsView} />
        <Stack.Screen name="AdminProfile" component={AdminProfileScreen} />
        <Stack.Screen name="AdminSettings" component={AdminSettingsView} /> */}

        {/* '/forgot' */}
        <Stack.Screen name="Forgot" component={Forgot} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
